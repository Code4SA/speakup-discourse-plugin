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

      if (navigator.geolocation) {
        $('.cllr .btn.locate')
          .removeClass('hidden')
          .on('click', self.councillorGeolocate);
      }
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

    self.councillorGeolocate = function(e) {
      var $btn = $('.cllr .btn.locate');

      function foundLocation(position) {
        lat = position.coords.latitude;
        lng = position.coords.longitude;
        $('form.cllr [name=address]').val(lat + ',' + lng);
        $('form.cllr').submit();
      }

      function noLocation() {
        $btn.val('Use your location');
        alert('Sorry, your browser was unable to determine your location.');
      }

      $btn.val('Locating...');
      navigator.geolocation.getCurrentPosition(foundLocation, noLocation, {timeout:10000});
    };
  };

  window.Speakup = new Speakup();
  window.Speakup.init();
});
