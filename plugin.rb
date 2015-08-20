# name: Speak Up Discourse Plugin
# about: Extra features for Speak Up Discourse
# version: 0.2
# authors: Code for South Africa (@code4sa)

gem 'mailchimp-api', '2.0.6', require_name: 'mailchimp'
gem 'useragent', '0.10.0', require_name: 'useragent'

after_initialize do
  # load the libraries
  $:.unshift(File.expand_path('../lib', __FILE__))

  require 'topic_embeds'
  require 'user_mailchimp_observer'
  require 'content_controller'
  require 'facebook_users'
  require 'discourse_mxit'
  require 'mobile_redirect'

  User.add_observer UserMailChimpObserver.instance

  Discourse::Application.routes.append do
    mount ::MiniCmsPlugin::Engine, at: '/cms'
    mount ::DiscourseMxit::Engine, at: '/mxit'
  end
end

register_asset "javascripts/speakup/speakup.js"
register_asset "stylesheets/speakup.scss"

register_custom_html footer: File.read(File.expand_path('../assets/html/footer.html', __FILE__))
