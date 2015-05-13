require "qiita/elasticsearch/nodes/match_node"

module Qiita
  module Elasticsearch
    module Nodes
      class MultiMustNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        def initialize(tokens)
          @tokens = tokens
        end

        def to_hash
          {
            "bool" => {
              "must" => must_queries,
            },
          }
        end

        private

        # @return [Array<Hash>] Queries to be used as a value of `must` property of bool query.
        def must_queries
          @tokens.map do |token|
            MatchNode.new(token).to_hash
          end
        end
      end
    end
  end
end
