require 'json'
require 'logger'

module Lsp
  class FileLanguageServer
    def initialize(implementation, input = $stdin, output = $stdout, logger: Logger.new(nil))
      @implementation = implementation
      @input = input
      @output = output
      @logger = logger
    end

    def start
      prepare

      loop do
        headers = {}
        loop do
          header_line = input.readline.strip
          if header_line.empty?
            if headers.empty?
              redo
            else
              break
            end
          end
          header_name, header_value = header_line.split(":", 2)
          headers[header_name] = header_value.strip
        end

        body_raw = input.read(headers["Content-Length"].to_i)
        body_json = JSON.parse(body_raw, symbolize_names: true)
        logger.info("RECV #{body_json}")
        if body_json.key?(:id)
          implementation.request(
            body_json.fetch(:id),
            body_json.fetch(:method),
            body_json.fetch(:params))
        else
          implementation.notify(
            body_json.fetch(:method),
            body_json.fetch(:params))
        end
      end
    rescue EOFError
    end

    def prepare
      implementation.language_server = self
    end

    def response(id, result, error)
      payload = {
        jsonrpc: "2.0",
        id: id,
        result: result,
        error: error,
      }
      output.write(build_message(payload))
      output.flush
      logger.info("SEND #{payload}")
    end

    def build_message(hash)
      json = hash.to_json
      "Content-Length: #{json.size}\r\n\r\n#{json}"
    end

    attr_reader :implementation, :input, :output, :logger
  end
end
