require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class Parser
      # @param [Array<String>, nil] filterable_fields
      def initialize(filterable_fields: nil)
        @filterable_fields = filterable_fields
      end

      # @param [String] query_string Raw query string given from search user.
      # @return [Array<Qiita::Elasticsearch::Token>]
      def parse(query_string)
        tokenizer.tokenize(query_string)
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(filterable_fields: @filterable_fields)
      end
    end
  end
end
