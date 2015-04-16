require "qiita/elasticsearch/nodes/filter_node"
require "qiita/elasticsearch/nodes/query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class FilterableNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        # @param [Array<String>, nil] range_fields
        def initialize(tokens, hierarchal_fields: nil, matchable_fields: nil, range_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @range_fields = range_fields
          @tokens = tokens
        end

        def to_hash
          if filter_tokens.empty?
            QueryNode.new(
              not_filter_tokens,
              matchable_fields: @matchable_fields,
            ).to_hash
          else
            {
              "filtered" => {
                "filter" => FilterNode.new(
                  filter_tokens,
                  hierarchal_fields: @hierarchal_fields,
                  matchable_fields: @matchable_fields,
                  range_fields: @range_fields,
                ).to_hash,
                "query" => QueryNode.new(
                  not_filter_tokens,
                  matchable_fields: @matchable_fields,
                ).to_hash,
              }.reject do |key, value|
                value.empty?
              end,
            }
          end
        end

        private

        def filter_tokens
          @filter_tokens ||= @tokens.select(&:filter?)
        end

        def not_filter_tokens
          @not_filter_tokens ||= @tokens.reject(&:filter?)
        end
      end
    end
  end
end
