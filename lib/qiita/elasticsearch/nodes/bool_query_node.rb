require "qiita/elasticsearch/nodes/token_node"

module Qiita
  module Elasticsearch
    module Nodes
      class BoolQueryNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        def initialize(tokens, hierarchal_fields: nil, matchable_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          case
          when has_only_one_should_token?
            should_query
          when has_only_one_must_token?
            must_query
          else
            {
              "bool" => {
                "must" => must_queries,
                "must_not" => must_not_queries,
                "should" => should_queries,
              }.reject do |key, value|
                value.empty?
              end,
            }
          end
        end

        private

        def has_only_one_must_token?
          must_not_tokens.empty? && should_tokens.empty? && must_tokens.size == 1
        end

        def has_only_one_should_token?
          must_not_tokens.empty? && must_tokens.empty? && should_tokens.size == 1
        end

        def must_not_queries
          must_not_tokens.map do |token|
            Nodes::TokenNode.new(
              token,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
            ).to_hash
          end
        end

        def must_not_tokens
          @must_not_tokens ||= @tokens.select(&:must_not?)
        end

        def must_query
          Nodes::TokenNode.new(
            must_tokens.first,
            hierarchal_fields: @hierarchal_fields,
            matchable_fields: @matchable_fields,
          ).to_hash
        end

        def must_queries
          must_tokens.map do |token|
            Nodes::TokenNode.new(
              token,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
            ).to_hash
          end
        end

        def must_tokens
          @must_tokens ||= @tokens.select(&:must?)
        end

        def should_query
          Nodes::TokenNode.new(
            should_tokens.first,
            matchable_fields: @matchable_fields,
          ).to_hash
        end

        def should_queries
          should_tokens.map do |token|
            Nodes::TokenNode.new(
              token,
              matchable_fields: @matchable_fields,
            ).to_hash
          end
        end

        def should_tokens
          @should_tokens ||= @tokens.select(&:should?)
        end
      end
    end
  end
end
