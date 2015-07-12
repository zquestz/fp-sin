require 'helper'

class TestFpSinApp < Minitest::Test
  include Rack::Test::Methods

  def app
    FpSinApp
  end
  
  def current_url
    "#{last_request.env['rack.url_scheme']}://#{last_request.env['HTTP_HOST']}"
  end

  def test_front_page_essentials
    get '/'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), 'favicon.png', 'logo.png', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end
  
  def test_main_css
    get '/main.css'
    assert last_response.ok?
    assert last_response.body.include?('background')
  end
  
  def test_404
    get '/fake/path'
    assert_equal 404, last_response.status
    assert last_response.body.include?(I18n.translate('http_not_found'))
  end

  def test_login
    get '/login'
    assert_equal 200, last_response.status
    assert last_response.body.include?(I18n.translate('login'))
  end

  def test_signup
    get '/signup'
    assert_equal 200, last_response.status
    assert last_response.body.include?(I18n.translate('sign_up'))
  end

  # Users should be gated only for admin users.
  def test_users
    get '/users'
    assert_equal 302, last_response.status
  end
end
