require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Array<String>, nil] filterable_fields
      # @param [Array<String>, nil] hierarchal_fields
      # @param [Array<String>, nil] matchable_fields
      # @param [Array<String>, nil] range_fields
      def initialize(hierarchal_fields: nil, filterable_fields: nil, matchable_fields: nil, range_fields: nil)
        @hierarchal_fields = hierarchal_fields
        @filterable_fields = filterable_fields
        @matchable_fields = matchable_fields
        @range_fields = range_fields
      end

      # @param [String] query_string Raw query string
      # @return [Hash]
      def build(query_string)
        tokens = tokenizer.tokenize(query_string)
        if tokens.size.zero?
          Nodes::NullNode.new.to_hash
        else
          Nodes::OrSeparatableNode.new(
            tokens,
            hierarchal_fields: @hierarchal_fields,
            matchable_fields: @matchable_fields,
            range_fields: @range_fields,
          ).to_hash
        end
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(filterable_fields: @filterable_fields)
      end
    end
  end
end
