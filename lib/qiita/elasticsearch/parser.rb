require "qiita/elasticsearch/tokenizer"
require "qiita/elasticsearch/tokens"

module Qiita
  module Elasticsearch
    class Parser
      # @param [Array<String>, nil] filterable_fields
      def initialize(filterable_fields: nil)
        @filterable_fields = filterable_fields
      end

      # @param [String] query_string Raw query string given from search user.
      # @return [Qiita::Elasticsearch::Tokens]
      def parse(query_string)
        Tokens.new(tokenizer.tokenize(query_string))
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(filterable_fields: @filterable_fields)
      end
    end
  end
end
