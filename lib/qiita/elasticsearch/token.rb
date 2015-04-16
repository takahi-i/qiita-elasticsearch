module Qiita
  module Elasticsearch
    class Token
      RANGE_TERM_REGEXP = /\A(?<operand>\<|\<=|\>|\>=)(?<query>.*)\z/

      attr_reader :field_name, :term

      def initialize(field_name: nil, minus: nil, quoted: nil, term: nil, token_string: nil)
        @field_name = field_name
        @minus = minus
        @quoted = quoted
        @term = term
        @token_string = token_string
      end

      def downcased_term
        @downcased_term ||= term.downcase
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

      # @return [true, false] True if this token is for phrase matching
      # @note `Express OR "Ruby on Rails"`
      #                   ^^^^^^^^^^^^^^^
      #                        This
      def quoted?
        !!@quoted
      end

      # @return [String, nil]
      # @example Suppose @term is "created_at:>=2015-04-16"
      #   range_parameter #=> "gte"
      def range_parameter
        range_match[:operand] ? operand_map[range_match[:operand]] : nil
      end

      # @return [String, nil]
      # @example Suppose @term is "created_at:>=2015-04-16"
      #   range_query #=> "2015-04-16"
      def range_query
        range_match[:query]
      end

      private

      def range_match
        @range_match ||= RANGE_TERM_REGEXP.match(@term) || {}
      end

      def operand_map
        {
          ">" => "gt",
          ">=" => "gte",
          "<" => "lt",
          "<=" => "lte",
        }
      end
    end
  end
end
