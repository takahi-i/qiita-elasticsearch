require "qiita/elasticsearch/tokenizer"
require "qiita/elasticsearch/tokens"

module Qiita
  module Elasticsearch
    class Parser
      # @param [Array<String>, nil] fields Available field names
      def initialize(fields: nil)
        @fields = fields
      end

      # @param [String] query_string Raw query string given from search user.
      # @return [Qiita::Elasticsearch::Tokens]
      def parse(query_string)
        Tokens.new(tokenizer.tokenize(query_string))
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new
      end
    end
  end
end
