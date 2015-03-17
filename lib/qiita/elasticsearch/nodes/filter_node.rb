require "qiita/elasticsearch/nodes/token_node"

module Qiita
  module Elasticsearch
    module Nodes
      class FilterNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        def initialize(token, hierarchal_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          {
            "_cache" => true,
            "bool" => {
              "must" => must_queries,
              "must_not" => must_not_queries,
            }.reject do |key, value|
              value.empty?
            end,
          }
        end

        private

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
      end
    end
  end
end
