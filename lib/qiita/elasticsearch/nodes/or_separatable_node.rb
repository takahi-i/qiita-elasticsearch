require "qiita/elasticsearch/nodes/filterable_node"
require "qiita/elasticsearch/nodes/null_node"

module Qiita
  module Elasticsearch
    module Nodes
      class OrSeparatableNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] matchable_fields
        # @param [Array<String>, nil] range_fields
        def initialize(tokens, hierarchal_fields: nil, matchable_fields: nil, range_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @matchable_fields = matchable_fields
          @range_fields = range_fields
          @tokens = tokens
        end

        def to_hash
          case tokens_grouped_by_or_token.size
          when 0
            Nodes::NullNode.new.to_hash
          when 1
            Nodes::FilterableNode.new(
              tokens_grouped_by_or_token.first,
              hierarchal_fields: @hierarchal_fields,
              matchable_fields: @matchable_fields,
              range_fields: @range_fields,
            ).to_hash
          else
            {
              "bool" => {
                "should" => tokens_grouped_by_or_token.map do |tokens|
                  Nodes::FilterableNode.new(
                    tokens,
                    hierarchal_fields: @hierarchal_fields,
                    matchable_fields: @matchable_fields,
                    range_fields: @range_fields,
                  ).to_hash
                end,
              },
            }
          end
        end

        private

        # @return [Array<Array<Qiita::Elasticsearch::Token>>]
        def tokens_grouped_by_or_token
          @tokens_grouped_by_or_token ||= @tokens.each_with_object([[]]) do |token, groups|
            if token.or?
              groups << []
            else
              groups.last << token
            end
          end.reject(&:empty?)
        end
      end
    end
  end
end
