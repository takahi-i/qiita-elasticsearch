require "active_support/core_ext/date"
require "active_support/core_ext/integer"
require "qiita/elasticsearch/range_token"

module Qiita
  module Elasticsearch
    class DateToken < RangeToken
      # @note Matches to "YYYY", "YYYY-MM" and "YYYY-MM-DD"
      DATE_REGEXP = /\A
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
      def to_hash
        case
        when range_parameter
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
        when date_match
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
        else
          {
            "term" => {
              @field_name => downcased_term,
            },
          }
        end
      end

      private

      def date_match
        @date_match ||= DATE_REGEXP.match(range_query || @term)
      end

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
    end
  end
end
