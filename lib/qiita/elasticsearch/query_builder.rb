require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Array<String>, nil] date_fields
      # @param [Array<String>, nil] downcased_fields
      # @param [Array<String>, nil] filterable_fields
      # @param [Array<String>, nil] hierarchal_fields
      # @param [Array<String>, nil] matchable_fields
      # @param [Array<String>, nil] range_fields
      def initialize(date_fields: nil, downcased_fields: nil, hierarchal_fields: nil, filterable_fields: nil, matchable_fields: nil, range_fields: nil)
        @date_fields = date_fields
        @downcased_fields = downcased_fields
        @filterable_fields = filterable_fields
        @hierarchal_fields = hierarchal_fields
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
          Nodes::OrSeparatableNode.new(tokens).to_hash
        end
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(
          date_fields: @date_fields,
          downcased_fields: @downcased_fields,
          filterable_fields: @filterable_fields,
          hierarchal_fields: @hierarchal_fields,
          matchable_fields: @matchable_fields,
          range_fields: @range_fields,
        )
      end
    end
  end
end
