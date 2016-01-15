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
</div>';

    self.init = function() {
      self.injectContent();

      // show it?
      self.toggleHomepage(window.location.pathname);

      Discourse.PageTracker.current().on('change', function(url) {
        self.toggleHomepage(url);
      });
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
  };

  window.Speakup = new Speakup();
  window.Speakup.init();
});
