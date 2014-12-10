# Allow users to sign up with Facebook without an email address.
# We add a fake @facebook.com address just to satisfy the presence
# and uniqueness requirement.
Auth::FacebookAuthenticator.class_eval do
  alias_method :old_after_authenticate, :after_authenticate
  def after_authenticate(auth_token)
    result = old_after_authenticate(auth_token)

    if result.email.blank?
      # try usernam@facebook.com, then their account id
      if !result.extra_data[:username].blank?
        result.email = "#{result.extra_data[:username]}@facebook.com"
      else
        result.email = "#{result.extra_data[:facebook_user_id]}@facebook"
      end

      result.email_valid = true
    end

    result
  end

  alias_method :old_after_create_account, :after_create_account
  def after_create_account(user, auth)
    old_after_create_account(user, auth)

    # try to minimise the number of emails we send to the fake address
    user.email_digests = false if user.placeholder_email?
  end
end

# add a helper method to the user class to find these placeholder addresses
User.class_eval do
  def placeholder_email?
    email.end_with? "@facebook"
  end

  # try to minimise the number of emails we send to the fake address
  def email_direct?
    !placeholder_email? and @email_direct
  end
end
