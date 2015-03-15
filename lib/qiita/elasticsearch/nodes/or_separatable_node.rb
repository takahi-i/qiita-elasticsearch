require "qiita/elasticsearch/nodes/bool_query_node"
require "qiita/elasticsearch/nodes/null_node"

module Qiita
  module Elasticsearch
    module Nodes
      class OrSeparatableNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] matchable_fields
        def initialize(tokens, matchable_fields: nil)
          @matchable_fields = matchable_fields
          @tokens = tokens
        end

        def to_hash
          case tokens_grouped_by_or_token.size
          when 0
            Nodes::NullNode.new.to_hash
          when 1
            Nodes::BoolQueryNode.new(
              tokens_grouped_by_or_token.first,
              matchable_fields: @matchable_fields,
            ).to_hash
          else
            {
              "bool" => {
                "should" => tokens_grouped_by_or_token.map do |tokens|
                  Nodes::BoolQueryNode.new(
                    tokens,
                    matchable_fields: @matchable_fields,
                  ).to_hash
                end,
              },
            }
          end
        end

        private

        # @return [Array<Array<Qiita::Elasticsearch::Token>>]
        def tokens_grouped_by_or_token
          @tokens_grouped_by_or_token ||= @tokens.inject([[]]) do |groups, token|
            if token.or?
              groups << []
            else
              groups.last << token
            end
            groups
          end.reject(&:empty?)
        end
      end
    end
  end
end
