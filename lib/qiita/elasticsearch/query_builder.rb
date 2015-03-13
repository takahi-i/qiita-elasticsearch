require "qiita/elasticsearch/nodes/bool_query_node"
require "qiita/elasticsearch/nodes/null_node"
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
        if tokens.size.zero?
          Nodes::NullNode.new.to_hash
        else
          Nodes::BoolQueryNode.new(
            tokens,
            fields: @fields,
          ).to_hash
        end
      end

      private

      def parser
        @parser ||= Parser.new(filterable_fields: @filterable_fields)
      end
    end
  end
end
