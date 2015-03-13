require "qiita/elasticsearch/parser"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Hash] properties Properties to configure the query buider's behavior
      def initialize(properties = {})
        @properties = properties
      end

      # @todo Not implemented yet
      # @param [String] query_string Raw query string given from search user
      # @return [Qiita::Elasticsearch::Query]
      def build(query_string)
        parser.parse(query_string)
      end

      private

      def parser
        @parser ||= Parser.new
      end
    end
  end
end
