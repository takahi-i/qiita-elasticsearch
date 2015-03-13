require "qiita/elasticsearch/nodes/root_node"
require "qiita/elasticsearch/parser"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Array<String>, nil] fields Available field names
      # @param [Array<String>, nil] filterable_fields
      def initialize(fields: nil, filterable_fields: nil)
        @fields = fields
        @filterable_fields = filterable_fields
      end

      # @param [String] query_string Raw query string given from search user
      # @return [Hash]
      def build(query_string)
        tokens = parser.parse(query_string)
        Nodes::RootNode.new(tokens, fields: @fields).to_hash
      end

      private

      def parser
        @parser ||= Parser.new(filterable_fields: @filterable_fields)
      end
    end
  end
end
