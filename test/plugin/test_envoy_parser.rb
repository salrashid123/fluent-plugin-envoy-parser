
require "test-unit"
require "fluent/test"
require 'fluent/test/driver/output'
require "fluent/test/helpers"

require_relative '../../lib/fluent/plugin/parser_envoy'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

module ParserTest
  include Fluent
  include Fluent::Test::Helpers

  class EnvoyParserTest < ::Test::Unit::TestCase
    include ParserTest

    def setup
      Fluent::Test.setup
    end

    CONFIG_HTTP = %[
      log_format envoy_http
    ]

    CONFIG_TCP = %[
      log_format envoy_tcp
    ]    

    DEFAULT_HTTP_LOG = '[2019-01-05T17:50:14.669Z] "GET / HTTP/1.1" 200 - 0 945 184 181 "-" "curl/7.60.0" "bd2d6816-cbff-4288-a7c6-a7f5b053ad1a" "www.bbc.com" "151.101.52.81:443"'
    DEFAULT_TCP_LOG = '[2019-01-05T22:19:11.088Z] "- - -" 0 - 85 1408 164 - "-" "-" "-" "-" "151.101.52.81:443"'

    def create_driver(conf)      
      Fluent::Test::ParserTestDriver.new(Fluent::Plugin::EnvoyParser).configure(conf)
    end

    def test_basic_http
      d = create_driver(CONFIG_HTTP)
      d.instance.parse(DEFAULT_HTTP_LOG) {|_, v| assert_equal(
        {
          "authority"=>"www.bbc.com",
          "bytes_received"=>0,
          "bytes_sent"=>945,
          "duration"=>"0.184s",
          "method"=>"GET",
          "path"=>"/",
          "protocol"=>"HTTP/1.1",
          "response_code"=>200,
          "response_flags"=>"-",
          "upstream_host"=>"151.101.52.81:443",
          "user_agent"=>"curl/7.60.0",
          "x_envoy_upstream_service_time"=>"181",
          "x_forwarded_for"=>nil
        }, v)}
    end

    def test_basic_tcp
      d = create_driver(CONFIG_TCP)
      d.instance.parse(DEFAULT_TCP_LOG) {|_, v| assert_equal(
        {
          "bytes_received"=>85,
          "bytes_sent"=>1408,
          "duration"=>"0.164s",
          "upstream_host"=>"151.101.52.81:443"
        }, v)}
    end    

  end
end


