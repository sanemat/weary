require 'weary'
require 'rack'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].each {|f| require f }

WebMock.disable_net_connect!