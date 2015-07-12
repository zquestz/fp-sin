# fp-sin 0.2.0
# By: Josh Ellithorpe April 2011-2015
# Simple Sinatra shell with all the goodies.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, 'Ruby 1.9.2 required' if RUBY_VERSION < '1.9.2'

# Add lib directory to load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Require needed libs
require 'fiber'
require 'rack/fiber_pool'
require 'rack/session/cookie'
require 'sinatra'
require 'sinatra/flash'
require 'tilt/haml'
require 'tilt/sass'
require 'sinatra/activerecord'
require 'sinatra/i18n'
require 'sass'
require 'cache_proxy'
require 'resolv'
require 'em-resolv-replace' unless test?
require 'mime/types'
require 'dalli'
require 'hashify'
require 'em-synchrony/em-http'
require 'em-synchrony/activerecord'
require 'sinatra-authentication'

# Main application class.
class FpSinApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')
  set :memcached, '127.0.0.1:11211'
  set :caching, true
  set :cache_timeout, 120
  set :database_file, File.join('config', 'database.yml')
  set :cache, settings.caching ? Dalli::Client.new(settings.memcached, {:namespace => 'fps_', :expires_in => settings.cache_timeout}) : CacheProxy.new()

  use Rack::FiberPool, :size => 100 unless test?
  use Rack::Session::Cookie, :key => 'rack.session',
                           #:domain => 'foo.com',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'sdklfjklasdjfiowij547io45u9jslifj93',
                           :old_secret => '3948309257384719814543645767'

  register Sinatra::I18n
  register Sinatra::ActiveRecordExtension
  register Sinatra::Flash
  register Sinatra::SinatraAuthentication

  set :sinatra_authentication_view_path, "#{File.join(Pathname(__FILE__).dirname.expand_path, "views", "auth")}"

  get '/' do
    haml :index
  end
  
  get '/main.css' do
    cache_control :public, :must_revalidate, :max_age => (settings.cache_timeout * 10)
    set_content_type(:css)
    scss :main
  end
    
  # Page not found handler
  not_found do
    flash.now[:error] = t('http_not_found')
    haml :index
  end

  # Error handler
  error do
    flash.now[:error] = t('http_error')
    haml :index
  end
  
  helpers do
    # Automatically sets content-type header by file extension.
    def set_content_type(format)
      mime_type = MIME::Types.of("format.#{format}").first.content_type rescue 'text/html'
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
        parameters += "#{attribute}=\"#{value}\" "
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
  end

end
