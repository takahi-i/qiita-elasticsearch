module Qiita
  module Elasticsearch
    class Tokens
      include Enumerable

      # @param [Array<Qiita::Elasticsearch::Token>] tokens
      def initialize(tokens)
        @tokens = tokens
      end

      # @note Override
      def each(&block)
        @tokens.each(&block)
      end
    end
  end
end
