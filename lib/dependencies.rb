require 'fiber'
require 'rack/fiber_pool'
require 'rack/session/cookie'
require 'sinatra'
require 'sinatra/flash'
require 'application_helper'
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
