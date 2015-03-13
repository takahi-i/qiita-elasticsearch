require "qiita/elasticsearch/nodes/bool_query_node"
require "qiita/elasticsearch/nodes/match_query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class RootNode
        # @param [Qiita::Elasticsearch::Tokens] tokens
        # @param [Array<String>, nil] fields Available field names
        def initialize(tokens, fields: nil)
          @fields = fields
          @tokens = tokens
        end

        def to_hash
          if @tokens.has_only_one_positive_token?
            Nodes::MatchQueryNode.new(@tokens.first.term, fields: @fields).to_hash
          else
            Nodes::BoolQueryNode.new(@tokens, fields: @fields).to_hash
          end
        end
      end
    end
  end
end
