# allow embedding through topic ids or URLs
ApplicationController.class_eval do
  prepend_before_filter :redirect_to_mobile

  def redirect_to_mobile
    # don't redirect on password reset
    return if request.path =~ /\/users\/password-reset/

    ua = UserAgent.parse(request.env['HTTP_USER_AGENT'])

    if params[:nomobile] != "1" and \
      # BB before 10
      (ua.platform == "BlackBerry" and ua.version < "10")\
      or (ua.browser =~ /Nokia/)\
      or (ua.os =~ /Opera Mini/)
      
      redirect_to 'http://m.speakupmzansi.org.za' + request.path
    end
  end
end

