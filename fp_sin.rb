# fp-sin 0.2.0
# By: Josh Ellithorpe 2011-2015
# Simple Sinatra shell with all the goodies.
# thin -R config.ru start
# http://localhost:3000/

# Add lib directory to load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Require 3rdparty deps
require "dependencies"
# Require our libs
require 'cache_proxy'
require 'hashify'
require 'helpers'

# Main application class.
class FpSinApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')
  set :memcached, '127.0.0.1:11211'
  set :caching, true
  set :cache_timeout, 120
  set :database_file, File.join('config', 'database.yml')
  set :cache, settings.caching ? Dalli::Client.new(settings.memcached, {:namespace => 'fps_', :expires_in => settings.cache_timeout}) : CacheProxy.new()
  set :sinatra_authentication_view_path, "#{File.join(Pathname(__FILE__).dirname.expand_path, "views", "auth")}"
  set :public_folder, File.join(File.dirname(__FILE__), 'public')
  set :static_cache_control, [:public, :must_revalidate,
                              :max_age => (settings.cache_timeout * 10)]

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

  helpers ApplicationHelpers

  get '/' do
    haml :index
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
