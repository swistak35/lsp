module Lsp
  TextDocumentIdentifier = Struct.new(:uri)

  TextDocumentHoverRequest = Struct.new(:text_document, :position)
  InitializeRequest = Struct.new(:root_uri)

  NoopResponse = Struct.new(:result, :error)

  module ResponseError
    class Base
      def initialize(code, message, data)
        @code = code
        @message = message
        @data = data
      end

      def to_h
        {
          code: @code,
          message: @message,
          data: @data,
        }
      end
    end

    class MethodNotFound < Base
      def initialize
        @code = -32601
        @message = "Method not found"
      end
    end
  end

  module LanguageServer
    LanguageServerError = Class.new(StandardError)
    NotImplementedError = Class.new(LanguageServerError)

    def request(id, method_name, params)
      response = case method_name
      when "textDocument/hover"
        handle_text_document_hover(
          TextDocumentHoverRequest.new(
            TextDocumentIdentifier.new(
              params.fetch(:textDocument)),
            params.fetch(:position)))
      when "initialize"
        handle_initialize(
          InitializeRequest.new(
            params.fetch(:rootUri)))
      else
        NoopResponse.new(nil, ResponseError::MethodNotFound.new)
      end
      @language_server.response(id, response.result, response.error.to_h)
    rescue NotImplementedError
      NoopResponse.new(nil, ResponseError::MethodNotFound.new)
    end

    def notify(method_name, params)
      case method_name
      when "textDocument/didOpen"
        handle_text_document_did_open
      end
    rescue NotImplementedError
    end

    attr_writer :language_server

    def handle_text_document_hover(request)
      raise NotImplementedError
    end

    def handle_initialize(request)
      raise NotImplementedError
    end

    def handle_text_document_did_open
      raise NotImplementedError
    end
  end
end

require 'lsp/file_language_server'
