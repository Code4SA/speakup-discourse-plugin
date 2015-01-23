module DiscourseMxit
  class Engine < ::Rails::Engine
    engine_name 'mxit'
    isolate_namespace DiscourseMxit
  end

  Engine.routes.draw do
    get '/users/:mxit_id' => 'discourse_mxit#get_user'
    post '/users' => 'discourse_mxit#create_user'
  end

  class DiscourseMxitController < Admin::AdminController
    def get_user
      mxit_id = params[:mxit_id]

      if mxit_id.present?
        # find a user with this id
        oauth = Oauth2UserInfo.where(provider: 'mxit', uid: mxit_id).first
        user = oauth.try(:user)
        if user
          user_serializer = UserSerializer.new(user, scope: guardian, root: 'user')
          render_json_dump(user_serializer)
          return
        end
      end

      render json: {user: {}}
    end

    def create_user
      # create a new mxit-based user
      unless SiteSetting.allow_new_registrations
        return fail_with("login.new_registrations_disabled")
      end

      mxit_id = params[:mxit_id]

      # are we already linked to an oauth provider?
      oauth = Oauth2UserInfo.where(provider: 'mxit', uid: mxit_id).first
      if oauth
        if oauth.user
          render json: {
            success: true,
            active: oauth.user.active?,
            user_id: oauth.user.id
          }
          return
        end
      else
        # create new oauth entry
        oauth = Oauth2UserInfo.new(
          uid: mxit_id,
          provider: 'mxit',
          email: params[:email],
          name: params[:username]
        )
      end

      email = params[:email]
      if email.present?
        # Does the user with this email exist?
        # If it does, we simply let the mxit user act as that user.
        user = User.where(email: email).first
      else
        # placeholder email
        email = "#{mxit_id}@mxit"
        user = nil
      end

      if not user
        remote_ip = params[:remote_ip]
        username = generate_username

        user_params = params.permit(
          :name,
        ).merge(
          email: email,
          ip_address: remote_ip,
          registration_ip_address: remote_ip,
          password: SecureRandom.hex,
          username: username,
        )
        user = User.new(user_params)
        user.email_digests = !user.placeholder_email?
      end

      user.active = true
      user.custom_fields['cellphone_number'] = params[:cellphone_number] if params[:cellphone_number].present?
      oauth.user = user

      if user.save
        user.enqueue_welcome_message('welcome_user')

        render json: {
          success: true,
          active: user.active?,
          user_id: user.id
        }
      else
        render json: {
          success: false,
          message: I18n.t(
            'login.errors',
            errors: user.errors.full_messages.join("\n")
          ),
          errors: user.errors.to_hash,
          values: user.attributes.slice('name', 'username', 'email')
        }
      end
    end

    protected
    def generate_username
      username = params[:username].gsub(/[^a-zA-Z0-9_]/, '_')

      # max 20 chars, less 3 for a potential random number to prevent clashes
      username = "MXit_#{username}"[0...User.username_length.end-3]

      # ensure it's unique
      candidate = username
      existing = User.find_by(username_lower: candidate.downcase)
      while not existing.nil?
        candidate = "#{username}#{rand(999)}"
        existing = User.find_by(username_lower: candidate.downcase)
      end

      return candidate
    end
  end
end

# update User class to show MXit as a linked account
User.class_eval do
  def associated_accounts
    result = []

    result << "Twitter(#{twitter_user_info.screen_name})" if twitter_user_info
    result << "Facebook(#{facebook_user_info.username})"  if facebook_user_info
    result << "Google(#{google_user_info.email})"         if google_user_info
    result << "Github(#{github_user_info.screen_name})"   if github_user_info
    result << "MXit(#{oauth2_user_info.uid})"             if oauth2_user_info and oauth2_user_info.provider == 'mxit'

    user_open_ids.each do |oid|
      result << "OpenID #{oid.url[0..20]}...(#{oid.email})"
    end

    result.empty? ? I18n.t("user.no_accounts_associated") : result.join(", ")
  end
end
