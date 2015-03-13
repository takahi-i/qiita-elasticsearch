require "qiita/elasticsearch/nodes/filter_query_node"
require "qiita/elasticsearch/nodes/match_query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class TokenNode
        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] fields Available field names
        def initialize(token, fields: nil)
          @fields = fields
          @token = token
        end

        def to_hash
          if @token.field_name
            FilterQueryNode.new(@token).to_hash
          else
            MatchQueryNode.new(@token, fields: @fields).to_hash
          end
        end
      end
    end
  end
end
