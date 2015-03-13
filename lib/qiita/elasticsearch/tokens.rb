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

      def has_only_one_positive_token?
        !!negative_tokens.size.zero? && positive_tokens.size == 1
      end

      def negative_tokens
        @negative_tokens ||= @tokens.select(&:negative?)
      end

      def positive_tokens
        @positive_tokens ||= @tokens.select(&:positive?)
      end
    end
  end
end
