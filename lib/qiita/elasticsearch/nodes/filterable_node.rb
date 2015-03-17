require "qiita/elasticsearch/nodes/filter_node"
require "qiita/elasticsearch/nodes/query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class FilterableNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        def initialize(token, hierarchal_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          if filter_tokens.empty?
            QueryNode.new(
              not_filter_tokens,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
            )
          else
            {
              "filtered" => {
                "filter" => FilterNode.new(
                  filter_tokens,
                  hierarchal_fields: @hierarchal_fields,
                  matchable_fields: @matchable_fields,
                ),
                "query" => QueryNode.new(
                  not_filter_tokens,
                  hierarchal_fields: @hierarchal_fields,
                  matchable_fields: @matchable_fields,
                ),
              },
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
