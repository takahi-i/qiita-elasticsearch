require "qiita/elasticsearch/nodes/token_node"

module Qiita
  module Elasticsearch
    module Nodes
      class BoolQueryNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] fields Available field names
        def initialize(tokens, fields: nil)
          @fields = fields
          @tokens = tokens
        end

        def to_hash
          {
            "bool" => {
              "must" => @tokens.select(&:must?).map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end,
              "must_not" => @tokens.select(&:must_not?).map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end,
              "should" => @tokens.select(&:should?).map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end,
            },
          }
        end
      end
    end
  end
end
