module Lsp
  TextDocumentIdentifier = Struct.new(:uri)

  TextDocumentHoverRequest = Struct.new(:text_document, :position)

  module LanguageServer
    LanguageServerError = Class.new(StandardError)
    NotImplementedError = Class.new(LanguageServerError)
    UnknownMethodError = Class.new(LanguageServerError)

    def request(id, method_name, params)
      case method_name
      when "textDocument/hover"
        result = handle_text_document_hover(
          TextDocumentHoverRequest.new(
            TextDocumentIdentifier.new(
              params.fetch(:textDocument)),
            params.fetch(:position)))
      else raise UnknownMethodError
      end
      @language_server.response(id, result, nil)
    end

    attr_writer :language_server

    def handle_text_document_hover(request)
      raise NotImplementedError
    end
  end
end

require 'lsp/file_language_server'
