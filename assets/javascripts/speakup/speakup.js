$(function($) {
  var Speakup = function() {
    var self = this;

    /* yuck, javascript multi-line strings to let us inject HTML */

    var injectHtml = '\
<div class="speakup">\
  <div id="header">\
    <header>\
      <nav class="navbar navbar-default navbar-static-top">\
        <div class="container">\
          <ul class="nav navbar-nav nav-main">\
            <li>\
              <a href="http://info.speakupmzansi.org.za/election-promises/">Election Promises</a>\
            </li>\
            <li>\
              <a href="http://info.speakupmzansi.org.za/political-party-information/">Political Party Information</a>\
            </li>\
            <li>\
              <a href="http://info.speakupmzansi.org.za/state-province-summaries/">State of the Province Commitments</a>\
            </li>\
            <li>\
              <a href="http://info.speakupmzansi.org.za/resources/">Democracy Resources</a>\
            </li>\
            <li>\
              <a href="http://info.speakupmzansi.org.za/about-speak-mzansi/">About Speak Up Mzansi</a>\
            </li>\
            <li>\
              <a href="http://info.speakupmzansi.org.za/contact-us/">Contact Us</a>\
            </li>\
          </ul>\
\
          <ul class="nav navbar-right navbar-nav social-links hidden-xs">\
            <li>\
              <a href="https://twitter.com/@SpeakUpMzansi" class="navbar-link"><i class="fa fa-2x fa-twitter-square"></i></a>\
            </li>\
          </ul>\
        </div>\
      </nav>\
    </header>\
  </div>\
\
  <div id="speakup-homepage" style="display: none">\
    <div class="container">\
      <div class="row">\
        <!-- <div id="speakup-homepage-banner" class="col-sm-8"></div> -->\
        <div class="col-sm-8">\
          <h2>Who is Your Ward Councillor?</h2>\
          <h4>Find out who represents you where you live.</h4>\
\
          <form method="get" action="http://info.speakupmzansi.org.za/councillor/" class="cllr">\
            <label class="form-label" for="cllr_address">What is your address?</label>\
            <input type="text" class="form-control" id="cllr_address" name="address" value="" style="width: 400px; max-width: 100%">\
            <input type="submit" class="btn btn-primary" value="Find your councillor">\
            <input type="button" class="btn btn-default hidden locate" value="Use your browser\'s location">\
          </form>\
        </div>\
\
        <div class="col-sm-4 hidden-xs">\
          <a class="twitter-timeline" height="250" href="https://twitter.com/speakupmzansi" data-widget-id="534284291811721217">Tweets by @SpeakUpMzansi</a>\
          <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?\'http\':\'https\';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>\
        </div>\
      </div>\
    </div>\
  </div>\
</div>';

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

    self.injectContent = function() {
      $('#main-outlet').prepend($('<div id="speakup-inject-top"></div>'));
      $('#speakup-inject-top').html(injectHtml);

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
