require 'fluent/plugin/parser'

module Fluent
  module Plugin
    class EnvoyParser < Parser
      Plugin.register_parser('envoy', self)

      config_param :log_format, :string, :default => 'envoy_http'
      config_param :time_key, :string, :default => 'time'

      @REGEXP = nil
      DEFAULT_REGEXP = /^\[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>(?:[^\"]|\\.)*?)(?: +\S*)?) (?<protocol>\S+)?" (?<response_code>\S+) (?<response_flags>\S+) (?<bytes_received>\S+) (?<bytes_sent>\S+) (?<duration>\S+) (?<x_envoy_upstream_service_time>\S+) "(?<x_forwarded_for>[^\"]*)" "(?<user_agent>[^\"]*)" "(?<x_request_id>[^\"]*)" "(?<authority>[^\"]*)" "(?<upstream_host>[^\"]*)"?$/

      TIME_FORMAT = "%Y-%m-%dT%H:%M:%S"

      def initialize
        super
        @mutex = Mutex.new
      end

      def configure(conf={})
        super
        @REGEXP = /$^/ 

        if @log_format == 'envoy_http' or @log_format == 'envoy_tcp'
          @REGEXP = DEFAULT_REGEXP
        end

        @time_parser = time_parser_create(format: TIME_FORMAT)
      end

      def patterns
        {'format' => @REGEXP, 'time_format' => TIME_FORMAT}
      end

      def parse(text)
        m = @REGEXP.match(text)
        unless m
          yield nil, nil
          return
        end

        time = m['time']
        time = @mutex.synchronize { @time_parser.parse(time) }

        if @log_format == 'envoy_http'
            method = m['method']
            path = m['path']
            protocol = m['protocol']
            response_flags = m['response_flags']

            response_code = m['response_code'].to_i
            response_code = nil if response_code == 0

            bytes_sent = m['bytes_sent']
            bytes_sent = (bytes_sent == '-') ? nil : bytes_sent.to_i

            bytes_received = m['bytes_received']
            bytes_received = (bytes_received == '-') ? nil : bytes_received.to_i

            duration = m['duration']
            duration = (duration == '-') ? nil : (Float(duration)/1000).to_s + "s"

            x_envoy_upstream_service_time = m['x_envoy_upstream_service_time']
            x_request_id = m['x_request_id']
            authority = m['authority']
            upstream_host = m['upstream_host']

            user_agent = m['user_agent']
            user_agent = (user_agent == '-') ? nil : user_agent

            x_forwarded_for = m['x_forwarded_for']
            x_forwarded_for = (x_forwarded_for == '-') ? nil : x_forwarded_for

            record = {
              "method" => method,
              "path" => path,
              "protocol" => protocol,
              "response_code" => response_code,
              "response_flags" => response_flags,
              "bytes_received" => bytes_received,
              "bytes_sent" => bytes_sent,
              "duration" => duration,
              "x_envoy_upstream_service_time" => x_envoy_upstream_service_time,
              "x_forwarded_for" => x_forwarded_for,
              "user_agent" => user_agent,
              "authority" => authority,
              "upstream_host" => upstream_host
            }
          elsif @log_format == 'envoy_tcp'

            bytes_sent = m['bytes_sent']
            bytes_sent = (bytes_sent == '-') ? nil : bytes_sent.to_i

            bytes_received = m['bytes_received']
            bytes_received = (bytes_received == '-') ? nil : bytes_received.to_i

            duration = m['duration']
            duration = (duration == '-') ? nil : (Float(duration)/1000).to_s + "s"

            upstream_host = m['upstream_host']

            record = {
              "bytes_received" => bytes_received,
              "bytes_sent" => bytes_sent,
              "duration" => duration,
              "upstream_host" => upstream_host
            }
        end
        record["time"] = m['time'] if @keep_time_key

        yield time, record
      end
    end
  end
end
