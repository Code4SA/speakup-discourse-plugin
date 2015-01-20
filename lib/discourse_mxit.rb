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
      remote_ip = params[:remote_ip]
      username = params[:username]
      if username.present?
        username.gsub(/[^a-zA-Z0-9_]/, '_')
        username += '_MXit'
      end

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

      # Does the user with this email exist?
      # If it does, we simply let the mxit user act
      # as that user.
      user = params[:email].present? ? User.where(email: params[:email]).first : nil
      if not user
        user_params = params.permit(
          :name,
          :email,
          ).merge(
            ip_address: remote_ip,
            registration_ip_address: remote_ip,
            password: SecureRandom.hex,
            username: username,
          )
        user = User.new(user_params)
      end

      user.active = true
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
  end
end
