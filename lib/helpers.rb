module ApplicationHelpers
  # Automatically sets content-type header by file extension.
  def set_content_type(format)
    mime_type = MIME::Types.of("format.#{format}")
      .first
      .content_type rescue 'text/html'
    content_type mime_type, :charset => 'utf-8'
  end

  # Flushes memcache
  def flush_cache
    settings.cache.flush
  end

  # Current url of the application using rack env.
  def current_url
    @current_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  # Render login bar. Taken from sinatra-authentication, but added I18n translations.
  def render_login(html_attributes = {:class => ""})
    css_classes = html_attributes.delete(:class)
    parameters = ''
    html_attributes.each_pair do |attribute, value|
      parameters += %^#{attribute}="#{value}" ^
    end

    result = "<div id='sinatra-authentication-login-logout'>"
    if logged_in?
      logout_parameters = html_attributes
      logout_parameters.delete(:rel)
      result += "<a href='/users/#{current_user.id}/edit' class='#{css_classes} sinatra-authentication-edit' #{parameters}>#{t('edit_profile')}</a> - "
      result += "<a href='/logout' class='#{css_classes} sinatra-authentication-logout' #{logout_parameters}>#{t('logout')}</a>"
    else
      result += "<a href='/signup' class='#{css_classes} sinatra-authentication-signup' #{parameters}>#{t('sign_up')}</a> - "
      result += "<a href='/login' class='#{css_classes} sinatra-authentication-login' #{parameters}>#{t('login')}</a>"
    end

    result += "</div>"
  end

  # TODO: move to ViewHelpers
  # TODO: use manifest/versioning
  def url_for(path)
    if Sinatra::Application.production?
      path.gsub(/\.(css|js)$/, ".min.\\1")
    else
      path
    end
  end
end
