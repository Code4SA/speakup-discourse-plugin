$(function($) {
  var Speakup = function() {
    var self = this;

    self.init = function() {
      // inject the content
      $('#speakup-inject-top').html(self.render("javascripts/speakup/templates/speakup_template"));

      // show it?
      self.toggleHomepage(window.location.pathname == '/');

      Discourse.PageTracker.current().on('change', function(url) {
        self.toggleHomepage(url == '/');
      });
    };

    self.render = function(name) {
      var buffer = [];
      Ember.TEMPLATES[name]([], {data: {buffer: buffer}});
      return buffer.join('');
    };

    self.toggleHomepage = function(show) {
      $('#speakup-homepage').toggle(show);
    };
  };

  window.Speakup = new Speakup();
  window.Speakup.init();
});
