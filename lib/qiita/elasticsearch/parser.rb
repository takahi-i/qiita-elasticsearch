require "qiita/elasticsearch/query"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class Parser
      # @param [String] query_string Raw query string given from search user.
      # @return [Qiita::Elasticsearch::Query]
      def parse(query_string)
        Query.new(tokenizer.tokenize(query_string))
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new
      end
    end
  end
end
