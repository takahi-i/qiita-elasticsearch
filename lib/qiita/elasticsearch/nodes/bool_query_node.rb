require "qiita/elasticsearch/nodes/match_query_node"

module Qiita
  module Elasticsearch
    module Nodes
      class BoolQueryNode
        # @param [Qiita::Elasticsearch::Tokens] tokens
        # @param [Array<String>, nil] fields Available field names
        def initialize(tokens, fields: nil)
          @fields = fields
          @tokens = tokens
        end

        def to_hash
          hash = { "bool" => {} }
          if @tokens.positive_tokens.size.nonzero?
            hash["bool"]["must"] = @tokens.positive_tokens.map do |token|
              Nodes::TokenNode.new(token, fields: @fields).to_hash
            end
          end
          if @tokens.negative_tokens.size.nonzero?
            hash["bool"]["must_not"] = @tokens.negative_tokens.map do |token|
              Nodes::TokenNode.new(token, fields: @fields).to_hash
            end
          end
          hash
        end
      end
    end
  end
end
