require "qiita/elasticsearch/nodes/match_all_node"
require "qiita/elasticsearch/nodes/match_node"
require "qiita/elasticsearch/nodes/multi_should_node"

module Qiita
  module Elasticsearch
    module Nodes
      class QueryNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        def initialize(tokens, hierarchal_fields: nil, matchable_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          case @tokens.length
          when 0
            MatchAllNode.new.to_hash
          when 1
            MatchNode.new(
              @tokens.first,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
            )
          else
            MultiShouldNode.new(
              @tokens,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
            )
          end
        end
      end
    end
  end
end
