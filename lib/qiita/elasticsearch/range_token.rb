require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class RangeToken < Token
      RANGE_TERM_REGEXP = /\A(?<operand>\<=|\<|\>=|\>)(?<query>.*)\z/

      # @return [Hash]
      def to_hash
        if range_parameter
          {
            "range" => {
              @field_name => {
                range_parameter => range_query,
              },
            },
          }
        else
          {
            "term" => {
              @field_name => proper_cased_term,
            },
          }
        end
      end

      private

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
