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
          case
          when must_not_tokens.empty? && must_tokens.empty? && should_tokens.size == 1
            Nodes::TokenNode.new(should_tokens.first, fields: @fields).to_hash
          when must_not_tokens.empty? && should_tokens.empty? && must_tokens.size == 1
            Nodes::TokenNode.new(must_tokens.first, fields: @fields).to_hash
          else
            hash = { "bool" => {} }
            unless must_tokens.empty?
              hash["bool"]["must"] =  must_tokens.map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end
            end
            unless must_not_tokens.empty?
              hash["bool"]["must_not"] = must_not_tokens.map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end
            end
            unless should_tokens.empty?
              hash["bool"]["should"] = should_tokens.map do |token|
                Nodes::TokenNode.new(token, fields: @fields).to_hash
              end
            end
            hash
          end
        end

        private

        def must_tokens
          @must_tokens ||= @tokens.select(&:must?)
        end

        def must_not_tokens
          @must_not_tokens ||= @tokens.select(&:must_not?)
        end

        def should_tokens
          @should_tokens ||= @tokens.select(&:should?)
        end
      end
    end
  end
end
