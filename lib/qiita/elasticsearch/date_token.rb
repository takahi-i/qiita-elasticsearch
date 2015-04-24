require "active_support/core_ext/date"
require "active_support/core_ext/integer"
require "qiita/elasticsearch/concerns/range_operand_includable"
require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class DateToken < Token
      include Concerns::RangeOperandIncludable

      # @note Matches to "YYYY", "YYYY-MM" and "YYYY-MM-DD"
      DATE_PATTERN = /\A
        (?<year>\d{4})
        (?:
          -
          (?<month>\d{1,2})
          (?:
            -
            (?<day>\d{1,2})
          )?
        )?
      \z/x

      attr_writer :time_zone

      # @return [Hash]
      # @raise [InvalidQuery]
      def to_hash
        if date_match
          if range_parameter
            {
              "range" => {
                @field_name => {
                  range_parameter => range_query,
                  "time_zone" => @time_zone,
                }.reject do |key, value|
                  key == "time_zone" && value.nil?
                end,
              },
            }
          else
            {
              "range" => {
                @field_name => {
                  "gte" => beginning_of_range.to_s,
                  "lt" => end_of_range.to_s,
                  "time_zone" => @time_zone,
                }.reject do |key, value|
                  key == "time_zone" && value.nil?
                end,
              },
            }
          end
        else
          Nodes::NullNode.new.to_hash
        end
      end

      private

      # @return [Date]
      def beginning_of_range
        @beginning_of_range ||=
          case
          when date_match[:day]
            Date.new(date_match[:year].to_i, date_match[:month].to_i, date_match[:day].to_i)
          when date_match[:month]
            Date.new(date_match[:year].to_i, date_match[:month].to_i)
          else
            Date.new(date_match[:year].to_i)
          end
      end

      def date_match
        @date_match ||= DATE_PATTERN.match(range_query || @term)
      end

      # @return [Date]
      def end_of_range
        @end_of_range ||=
          case
          when date_match[:day]
            beginning_of_range + 1.day
          when date_match[:month]
            beginning_of_range + 1.month
          else
            beginning_of_range + 1.year
          end
      end

      # @note Override
      def has_invalid_term?
        !!date_match
      end
    end
  end
end
