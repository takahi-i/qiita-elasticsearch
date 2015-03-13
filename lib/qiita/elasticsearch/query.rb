module Qiita
  module Elasticsearch
    class Query
      # @param [Array<Qiita::Elasticsearch::Token>]
      def initialize(tokens)
        @tokens = tokens
      end

      # @todo This is a dummy implementation to a valid object.
      # @return [Hash]
      def to_hash
        {}
      end
    end
  end
end
