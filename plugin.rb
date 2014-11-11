# name: Speak Up Discourse Plugin
# about: Extra features for Speak Up Discourse
# version: 0.2
# authors: Code for South Africa (@code4sa)

gem 'mailchimp-api', '2.0.6', require_name: 'mailchimp'

after_initialize do

  # allow embedding through topic ids or URLs
  TopicEmbed.class_eval do
    class << self
      alias_method :old_topic_id_for_embed, :topic_id_for_embed

      def topic_id_for_embed(embed_url)
        # just a number
        return embed_url.to_i if embed_url =~ /^[0-9]+$/

        # /t/do-you-have-a-job/43/1
        if embed_url =~ %r{^/t/[^/]+/([0-9]+)}
          return $1
        end

        # fall back to old mechanism
        old_topic_id_for_embed
      end
    end
  end

  require 'mailchimp'
  require 'time'

  class UserMailChimpObserver < ActiveRecord::Observer
    # register users with mailchimp
    observe :user

    def initialize(*args)
      super(*args)

      @client = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
      @list_id = ENV['MAILCHIMP_LIST_ID']

      if @list_id.empty?
        raise ArgumentError.new("Please set the MAILCHIMP_LIST_ID environment variable.")
      end
    end

    def after_create(user)
      subscribe_user(user)
    end

    def before_destroy(user)
      unsubscribe_user(user)
    end

    def subscribe_user(user)
      if user.email and user.email != 'no_email' and user.has_attribute?('ip_address')
        Rails.logger.info("Subscribing user with MailChimp: #{user.email} from #{user.ip_address}")

        res = @client.lists.subscribe(@list_id, {email: user.email}, {
                                optin_ip: user.ip_address,
                                optin_time: Time.now.iso8601},
                                'html', false, true)

        Rails.logger.info("Result: #{res}")
      end
    end

    def unsubscribe_user(user)
      if user.email and user.email != 'no_email'
        Rails.logger.info("Unsubscribing user from MailChimp: #{user.email}")

        begin
          res = @client.lists.unsubscribe(@list_id, {email: user.email}, true, false, false)
          Rails.logger.info("Result: #{res}")
        rescue Mailchimp::EmailNotExistsError => e
          Rails.logger.info("Couldn't unsubscribe user, ignoring: #{e.message}")
        end
      end
    end
  end

  User.add_observer UserMailChimpObserver.instance
end
