require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class Query
      # @param [Array<Qiita::Elasticsearch::Token>] tokens
      def initialize(tokens)
        @tokens = tokens
      end

      # @return [Hash]
      def to_hash
        if has_empty_tokens?
          Nodes::NullNode.new.to_hash
        else
          Nodes::OrSeparatableNode.new(@tokens).to_hash
        end
      end

      private

      def has_empty_tokens?
        @tokens.size.zero?
      end
    end
  end
end
