# Raise an error if we don't have a compatible ruby version.
raise LoadError, 'Ruby 1.9.2 required' if RUBY_VERSION < '1.9.2'

# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

if 'development' == ENV['RACK_ENV']
  # This will exit when the server stops but there should probably be some kind
  # of locking mechanism to ensure there's only one watcher running
  fork do
    %x{ PATH=$(npm bin):$PATH gulp watch }
  end
end

# Startup the app
require 'fp_sin'
run FpSinApp
