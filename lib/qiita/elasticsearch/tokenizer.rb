require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class Tokenizer
      DEFAULT_FILTERABLE_FIELDS = []

      TOKEN_PATTERN = /
        (?<token_string>
          (?<minus>-)?
          (?:(?<field_name>\w+):)?
          (?:
            (?:"(?<quoted_term>.*?)(?<!\\)")
            |
            (?<term>\S+)
          )
        )
      /x

      # @param [Array<String>, nil] filterable_fields
      def initialize(filterable_fields: nil)
        @filterable_fields = filterable_fields
      end

      # @param [String] query_string Raw query string
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        query_string.scan(TOKEN_PATTERN).map do |token_string, minus, field_name, quoted_term, term|
          term ||= quoted_term
          if !field_name.nil? && !filterable_fields.include?(field_name)
            term = "#{field_name}:#{term}"
            field_name = nil
          end
          Token.new(
            field_name: field_name,
            minus: minus,
            quoted: !quoted_term.nil?,
            term: term,
            token_string: token_string,
          )
        end
      end

      private

      def filterable_fields
        @filterable_fields || DEFAULT_FILTERABLE_FIELDS
      end
    end
  end
end
