require "qiita/elasticsearch/errors"
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
      # @param [Array<String>, nil] int_fields
      # @param [Array<String>, nil] matchable_fields
      # @param [String, nil] time_zone
      def initialize(date_fields: nil, downcased_fields: nil, hierarchal_fields: nil, filterable_fields: nil, int_fields: nil, matchable_fields: nil, time_zone: nil)
        @date_fields = date_fields
        @downcased_fields = downcased_fields
        @filterable_fields = filterable_fields
        @hierarchal_fields = hierarchal_fields
        @int_fields = int_fields
        @matchable_fields = matchable_fields
        @time_zone = time_zone
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
      rescue Error
        Nodes::NullNode.new.to_hash
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(
          date_fields: @date_fields,
          downcased_fields: @downcased_fields,
          filterable_fields: @filterable_fields,
          hierarchal_fields: @hierarchal_fields,
          int_fields: @int_fields,
          matchable_fields: @matchable_fields,
          time_zone: @time_zone,
        )
      end
    end
  end
end
