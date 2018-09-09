module Lsp
  TextDocumentIdentifier = Struct.new(:uri)

  DidChangeTextDocumentParams = Struct.new(:text_document, :content_changes)
  TextDocumentContentChangeEvent = Struct.new(:text)
  VersionedTextDocumentIdentifier = Struct.new(:uri, :version)
  TextDocumentPositionParams = Struct.new(:text_document, :position)
  InitializeRequest = Struct.new(:root_uri)
  CompletionItem = Struct.new(:label) do
    def to_h
      {
        label: label,
      }
    end
  end
  TextEdit = Struct.new(:range, :new_text) do
    def to_h
      {
        range: range.to_h,
        newText: new_text,
      }
    end
  end

  Position = Struct.new(:line, :character) do
    def self.from_hash(line:, character:)
      new(line, character)
    end
  end
  Range = Struct.new(:start, :end) do
    def to_h
      {
        start: start.to_h,
        end: self.end.to_h,
      }
    end
  end
  Location = Struct.new(:uri, :range) do
    def to_h
      {
        uri: uri,
        range: range.to_h,
      }
    end
  end

  ResponseMessage = Struct.new(:result, :error) do
    def self.successful(result)
      new(result, nil)
    end

    def self.error(error)
      new(error, nil)
    end
  end

  TextDocumentHoverResult = Struct.new(:contents) do
    def to_h
      {
        contents: self.contents,
        range: nil,
      }
    end
  end

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
          TextDocumentPositionParams.new(
            TextDocumentIdentifier.new(
              URI(params.fetch(:textDocument).fetch(:uri))),
            Position.from_hash(params.fetch(:position))))
      when "textDocument/definition"
        handle_text_document_definition(
          TextDocumentPositionParams.new(
            TextDocumentIdentifier.new(
              URI(params.fetch(:textDocument).fetch(:uri))),
            Position.from_hash(params.fetch(:position))))
      when "initialize"
        handle_initialize(
          InitializeRequest.new(
            URI(params.fetch(:rootUri))))
      when "textDocument/completion"
        handle_text_document_completion(
          TextDocumentPositionParams.new(
            TextDocumentIdentifier.new(
              URI(params.fetch(:textDocument).fetch(:uri))),
            Position.from_hash(params.fetch(:position))))
      when "textDocument/didChange"
        handle_text_document_did_change(
          DidChangeTextDocumentParams.new(
            VersionedTextDocumentIdentifier.new(
              URI(params.fetch(:textDocument).fetch(:uri)),
              params.fetch(:textDocument).fetch(:version)),
            params.fetch(:contentChanges).map do |contentChange|
              next if contentChange[:range]
              TextDocumentContentChangeEvent.new(
                contentChange.fetch(:text))
            end.compact))
      else
        ResponseMessage.new(nil, ResponseError::MethodNotFound.new)
      end
      @language_server.response(
        id,
        to_result(response.result),
        to_result(response.error))
    rescue NotImplementedError
      ResponseMessage.new(nil, ResponseError::MethodNotFound.new)
    end

    def notify(method_name, params)
      case method_name
      when "textDocument/didOpen"
        handle_text_document_did_open
      end
    rescue NotImplementedError
    end

    def to_result(obj)
      case obj
      when Array
        obj.map {|elem| to_result(elem) }
      when NilClass
        nil
      else
        obj.to_h
      end
    end

    attr_writer :language_server

    def handle_text_document_hover(request)
      raise NotImplementedError
    end

    def handle_text_document_definition(request)
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
