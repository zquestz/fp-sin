# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Startup the app
require 'fp_sin'
run FpSinApp
