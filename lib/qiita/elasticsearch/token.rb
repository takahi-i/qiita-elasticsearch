module Qiita
  module Elasticsearch
    class Token
      # @return [String, nil]
      # @note `xxxxxxxxxxxx:yyyyyyyyyyy`
      #        ^^^^^^^^^^^^
      #         field_name
      attr_reader :field_name

      # @return [String]
      # @note `xxxxxxxxxxxx:yyyyyyyyyyy`
      #                     ^^^^^^^^^^^
      #                        term
      attr_reader :term

      # @return [Hash]
      attr_accessor :options

      # @param [true, false] downcased True if given term must be downcased on query representation
      # @param [String, nil] field_name Field name part
      # @param [true, false] negative True if this term represents negative token (e.g. "-Perl")
      # @param [true, false] quoted Given term is quoted or not
      # @param [true, false] filter True if this term should be used as filter
      # @param [String] term Term part
      # @param [String] token_string Original entire string
      # @param [Hash] options Optional search parameters
      def initialize(downcased: nil, field_name: nil, negative: nil, quoted: nil, filter: nil, term: nil, token_string: nil, options: nil)
        @downcased = downcased
        @field_name = field_name
        @negative = negative
        @quoted = quoted
        @filter = filter
        @term = term
        @token_string = token_string
        @options = options
      end

      # @return [true, false] True if its term must be treated with downcased
      def downcased?
        !!@downcased
      end

      def downcased_term
        @downcased_term ||= term.downcase
      end

      def filter?
        !!@filter || negative?
      end

      # @return [true, false] True if this token is for query
      def query?
        !sort? && !ignorable?
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
        !!@negative
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
        !negative?
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

      # @note Override me
      # @return [true, false] True if this token is for sort order (e.g. "sort:created-asc")
      def sort?
        field_name == "sort"
      end

      # @note Override me
      def to_hash
        fail NotImplementedError
      end

      # @note Override
      # @return [String]
      def to_s
        @token_string.to_s
      end

      # @note Override me if needed
      # @return [true, false]
      def type?
        false
      end

      private

      # @note Override me if needed
      # @return [true, false] True if its term is invalid value
      def has_invalid_term?
        false
      end

      # @return [true, false] True if this token has no meaning
      def ignorable?
        negative? && !field_name.nil? && has_invalid_term?
      end
    end
  end
end
