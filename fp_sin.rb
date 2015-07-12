# fp-sin 0.2.0
# By: Josh Ellithorpe 2011-2015
# Simple Sinatra shell with all the goodies.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, 'Ruby 1.9.2 required' if RUBY_VERSION < '1.9.2'

# Add lib directory to load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require "dependencies"

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
                           :secret => ENV['SESSION_SECRET'] || 'DEFAULT_SESSION_KEY',
                           :old_secret => ENV['OLD_SESSION_SECRET'] || 'DEFAULT_OLD_SESSION_KEY'

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
end
