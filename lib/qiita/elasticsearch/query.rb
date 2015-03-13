module Qiita
  module Elasticsearch
    class Query
      # @param [Array<Qiita::Elasticsearch::Token>]
      def initialize(tokens)
        @tokens = tokens
      end

      # @todo
      # @return [Hash]
      def to_hash
        if has_only_one_positive_token?
          @tokens.first.to_match_query_hash
        else
          hash = { "bool" => {} }
          hash["bool"]["must"] = positive_tokens.map(&:to_match_query_hash) if has_positive_token?
          hash["bool"]["must_not"] = negative_tokens.map(&:to_match_query_hash) if has_negative_token?
          hash
        end
      end

      private

      def has_negative_token?
        !!negative_tokens.size.nonzero?
      end

      def has_positive_token?
        !!positive_tokens.size.nonzero?
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
