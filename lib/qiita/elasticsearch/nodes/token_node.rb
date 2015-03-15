require "qiita/elasticsearch/nodes/filter_query_node"
require "qiita/elasticsearch/nodes/match_query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class TokenNode
        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] matchable_fields
        def initialize(token, matchable_fields: nil)
          @matchable_fields = matchable_fields
          @token = token
        end

        def to_hash
          if @token.field_name
            FilterQueryNode.new(@token).to_hash
          else
            MatchQueryNode.new(@token, matchable_fields: @matchable_fields).to_hash
          end
        end
      end
    end
  end
end
