require "qiita/elasticsearch/nodes/token_node"

module Qiita
  module Elasticsearch
    module Nodes
      class BoolQueryNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] matchable_fields
        def initialize(tokens, matchable_fields: nil)
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          case
          when has_only_one_should_token?
            Nodes::TokenNode.new(should_tokens.first, matchable_fields: @matchable_fields).to_hash
          when has_only_one_must_token?
            Nodes::TokenNode.new(must_tokens.first, matchable_fields: @matchable_fields).to_hash
          else
            hash = { "bool" => {} }
            unless must_tokens.empty?
              hash["bool"]["must"] = must_tokens.map do |token|
                Nodes::TokenNode.new(token, matchable_fields: @matchable_fields).to_hash
              end
            end
            unless must_not_tokens.empty?
              hash["bool"]["must_not"] = must_not_tokens.map do |token|
                Nodes::TokenNode.new(token, matchable_fields: @matchable_fields).to_hash
              end
            end
            unless should_tokens.empty?
              hash["bool"]["should"] = should_tokens.map do |token|
                Nodes::TokenNode.new(token, matchable_fields: @matchable_fields).to_hash
              end
            end
            hash
          end
        end

        private

        def has_only_one_must_token?
          must_not_tokens.empty? && should_tokens.empty? && must_tokens.size == 1
        end

        def has_only_one_should_token?
          must_not_tokens.empty? && must_tokens.empty? && should_tokens.size == 1
        end

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
