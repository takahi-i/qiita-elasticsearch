require "qiita/elasticsearch/nodes/match_node"

module Qiita
  module Elasticsearch
    module Nodes
      class MultiShouldNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] matchable_fields
        def initialize(tokens, matchable_fields: nil)
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          {
            "bool" => {
              "should" => should_queries,
            },
          }
        end

        private

        # @return [Array<Hash>] Queries to be used as a value of `should` property of bool query.
        def should_queries
          @tokens.map do |token|
            MatchNode.new(
              token,
              matchable_fields: @matchable_fields,
            ).to_hash
          end
        end
      end
    end
  end
end
