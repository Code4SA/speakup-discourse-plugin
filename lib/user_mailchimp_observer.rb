require 'mailchimp'
require 'time'

class UserMailChimpObserver < ActiveRecord::Observer
  # register users with mailchimp
  observe :user

  def initialize(*args)
    super(*args)

    api_key = ENV['MAILCHIMP_API_KEY']
    @list_id = ENV['MAILCHIMP_LIST_ID']

    if Rails.env.production? and (api_key.blank? or @list_id.blank?)
      raise ArgumentError.new("Please set the MAILCHIMP_LIST_ID and MAILCHIMP_API_KEY environment variables.")
    end

    # no client indicates we're disabled
    @client = api_key.blank? ? nil : Mailchimp::API.new(api_key)
  end

  def after_create(user)
    subscribe_user(user) if @client
  end

  def before_destroy(user)
    unsubscribe_user(user) if @client
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

