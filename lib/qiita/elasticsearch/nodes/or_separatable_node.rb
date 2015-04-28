require "qiita/elasticsearch/nodes/filterable_node"
require "qiita/elasticsearch/nodes/any_node"

module Qiita
  module Elasticsearch
    module Nodes
      class OrSeparatableNode
        # @param [Array<Qiita::Elasticsearch::Tokens>] tokens
        def initialize(tokens)
          @tokens = tokens
        end

        def to_hash
          case tokens_grouped_by_or_token.size
          when 0
            Nodes::AnyNode.new.to_hash
          when 1
            Nodes::FilterableNode.new(tokens_grouped_by_or_token.first).to_hash
          else
            {
              "bool" => {
                "should" => tokens_grouped_by_or_token.map do |tokens|
                  Nodes::FilterableNode.new(tokens).to_hash
                end,
              },
            }
          end
        end

        private

        # @return [Array<Array<Qiita::Elasticsearch::Token>>]
        def tokens_grouped_by_or_token
          @tokens_grouped_by_or_token ||= @tokens.select(&:query?).each_with_object([[]]) do |token, groups|
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
