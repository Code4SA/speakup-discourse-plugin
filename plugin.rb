# name: Speak Up Discourse Plugin
# about: Extra features for Speak Up Discourse
# version: 0.2
# authors: Code for South Africa (@code4sa)

gem 'mailchimp-api', '2.0.6', require_name: 'mailchimp'

after_initialize do
  # load the libraries
  $:.unshift(File.expand_path('../lib', __FILE__))

  require 'topic_embeds'
  require 'user_mailchimp_observer'
  require 'content_controller'

  User.add_observer UserMailChimpObserver.instance

  Discourse::Application.routes.append do
    mount ::MiniCmsPlugin::Engine, at: '/cms'
  end
end

register_asset "javascripts/speakup/speakup.js"
register_asset "javascripts/speakup/templates/speakup_template.hbs"
register_asset "stylesheets/speakup.scss"

register_custom_html footer: File.read(File.expand_path('../assets/html/footer.html', __FILE__))
