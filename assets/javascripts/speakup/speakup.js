$(function($) {
  var Speakup = function() {
    var self = this;

    self.init = function() {
      self.injectContent();

      // show it?
      self.toggleHomepage(window.location.pathname);

      Discourse.PageTracker.current().on('change', function(url) {
        self.toggleHomepage(url);
      });
    };

    self.render = function(name) {
      // really hacky way of rendering handlebars templates
      var buffer = [];
      Ember.TEMPLATES[name]([], {data: {buffer: buffer}});
      return buffer.join('');
    };

    self.injectContent = function() {
      $('#main-outlet').prepend($('<div id="speakup-inject-top"></div>'));
      $('#speakup-inject-top').html(self.render("javascripts/speakup/templates/speakup_template"));

      $.getJSON('/cms/homepage-banner', function(data) {
        $('#speakup-homepage-banner').html(data.cooked);
      });
    };

    self.toggleHomepage = function(url) {
      // only show for urls like "/" and "/top"
      var show = (url.indexOf('/admin') !== 0) && 
                 (url.split('/').length <= 2);

      $('#speakup-homepage').toggle(show);
    };
  };

  window.Speakup = new Speakup();
  window.Speakup.init();
});
