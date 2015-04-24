require "qiita/elasticsearch/concerns/range_operand_includable"
require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class IntToken < Token
      include Concerns::RangeOperandIncludable

      INT_PATTERN = /\A\d+\z/

      # @return [Hash]
      # @raise [InvalidQuery]
      def to_hash
        if range_parameter && has_valid_range_query?
          {
            "range" => {
              @field_name => {
                range_parameter => range_query.to_i,
              },
            },
          }
        elsif has_valid_int_term?
          {
            "term" => {
              @field_name => @term.to_i,
            },
          }
        else
          Nodes::NullNode.new.to_hash
        end
      end

      private

      def has_invalid_range_query?
        has_range_query? && !has_valid_range_query?
      end

      # @note Override
      def has_invalid_term?
        range_parameter && has_invalid_range_query? || !has_valid_int_term?
      end

      def has_range_query?
        !range_query.nil?
      end

      def has_valid_int_term?
        INT_PATTERN === @term
      end

      def has_valid_range_query?
        INT_PATTERN === range_query
      end
    end
  end
end
