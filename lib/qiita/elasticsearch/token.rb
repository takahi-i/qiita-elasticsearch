module Qiita
  module Elasticsearch
    class Token
      def initialize(field_name: nil, minus: nil, quoted_term: nil, term: nil, token_string: nil)
        @field_name = field_name
        @minus = minus
        @quoted_term = quoted_term
        @term = term
        @token_string = token_string
      end

      # @note Override
      def to_s
        @token_string.dup
      end

      # @return [true, false] True if this token is for negative filter
      # @note `Ruby -Perl`
      #             ^^^^^
      #             This
      def negative?
        !positive?
      end

      # @return [true, false] True if this token is for OR filter
      # @note `Ruby OR Perl`
      #             ^^
      #            This
      def or?
        @token_string.downcase == "or"
      end

      # @return [true, false] Opposite of #negative?
      def positive?
        @minus.nil?
      end

      # @return [true, false] True if this token is for phrase matching
      # @note `Express OR "Ruby on Rails"`
      #                   ^^^^^^^^^^^^^^^
      #                        This
      def quoted?
        !@quoted_term.nil?
      end

      # @return [String] Term part of this token
      # @example
      #   tokenizer.tokenize("Ruby").first.term #=> "Ruby"
      #   tokenizer.tokenize('"Ruby"').first.term #=> "Ruby"
      def term
        @quoted_term || @term
      end

      # @return [Hash]
      def to_match_query_hash
        {
          "match" => {
            "_all" => term,
          },
        }
      end
    end
  end
end
