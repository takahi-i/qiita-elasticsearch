require "qiita/elasticsearch/nodes/root_node"
require "qiita/elasticsearch/parser"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Array<String>, nil] fields Available field names
      def initialize(fields: nil)
        @fields = fields
      end

      # @param [String] query_string Raw query string given from search user
      # @return [Hash]
      def build(query_string)
        tokens = parser.parse(query_string)
        Nodes::RootNode.new(tokens, fields: @fields).to_hash
      end

      private

      def parser
        @parser ||= Parser.new
      end
    end
  end
end
