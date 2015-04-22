module Qiita
  module Elasticsearch
    class Token
      attr_reader :field_name, :term

      # @param [true, false] downcased
      def initialize(downcased: nil, field_name: nil, minus: nil, quoted: nil, term: nil, token_string: nil)
        @downcased = downcased
        @field_name = field_name
        @minus = minus
        @quoted = quoted
        @term = term
        @token_string = token_string
      end

      # @return [true, false] True if its term must be treated with downcased
      def downcased?
        !!@downcased
      end

      def downcased_term
        @downcased_term ||= term.downcase
      end

      def to_hash
        fail NotImplementedError
      end

      def filter?
        !field_name.nil? || negative?
      end

      def must?
        !field_name.nil? && positive?
      end

      def must_not?
        negative?
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

      # @return [String] Downcased or not-downcased term
      def proper_cased_term
        if downcased?
          downcased_term
        else
          term
        end
      end

      # @return [true, false] True if this token is for phrase matching
      # @note `Express OR "Ruby on Rails"`
      #                   ^^^^^^^^^^^^^^^
      #                        This
      def quoted?
        !!@quoted
      end
    end
  end
end
