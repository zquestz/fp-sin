# fp-sin 0.1.0
# By: Josh Ellithorpe April 2011
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
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/i18n'
require 'less'
require 'cache_proxy'
require 'resolv'
require 'em-resolv-replace' unless test?
require 'mime/types'
require 'dalli'
require 'hashify'
require 'em-synchrony/em-http'

# Main application class.
class FpSinApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')
  set :memcached, 'localhost:11211'
  set :sockets, ['/opt/local/var/run/mysql5/mysqld.sock', 
                  '/var/run/mysqld/mysqld.sock', 
                  '/tmp/mysql.sock']
  set :caching, true
  set :cache_timeout, 120
  set :cache, settings.caching ? Dalli::Client.new(settings.memcached, {:namespace => 'fps_', :expires_in => settings.cache_timeout}) : CacheProxy.new()
  
  use Rack::FiberPool, :size => 100 unless test?

  register Sinatra::I18n
  
  configure do
    db_config = YAML.load_file(File.join('config', 'database.yml'))[settings.environment.to_s]
    db_config.merge!({'socket' => settings.sockets.find { |f| File.exist? f } }) if db_config['socket']
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.logger.level = Logger::INFO
  end
      
  get '/' do
    cache_control :public, :must_revalidate, :max_age => (settings.cache_timeout * 10)
    haml :index
  end
  
  get '/main.css' do
    cache_control :public, :must_revalidate, :max_age => (settings.cache_timeout * 10)
    set_content_type(:css)
    less :main
  end
    
  # Page not found handler
  not_found do
    @flash = {:error => t('http_not_found')}
    haml :index
  end

  # Error handler
  error do
    @flash = {:error => t('http_error')}
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
  end

end