require "qiita/elasticsearch/nodes/match_node"
require "qiita/elasticsearch/nodes/multi_must_node"

module Qiita
  module Elasticsearch
    module Nodes
      class QueryNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        def initialize(tokens)
          @tokens = tokens
        end

        def to_hash
          case @tokens.length
          when 0
            {}
          when 1
            MatchNode.new(@tokens.first).to_hash
          else
            MultiMustNode.new(@tokens).to_hash
          end
        end
      end
    end
  end
end
