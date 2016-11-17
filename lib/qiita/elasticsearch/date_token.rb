require "active_support/core_ext/date"
require "active_support/core_ext/integer"
require "qiita/elasticsearch/concerns/range_operand_includable"
require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class DateToken < Token
      include Concerns::RangeOperandIncludable

      attr_accessor :time_zone

      class BaseDateExpression
        FIELD_NAMES_TABLE = {
          "created" => "created_at",
          "updated" => "updated_at",
        }

        # @param [DateToken] token date token instance containing date expressions
        def initialize(token)
          @token = token
        end

        def match
          @match ||= self.class::PATTERN.match(@token.range_query || @token.term)
        end

        def to_hash
          fail NotImplementedError
        end

        # e.g. created:2000-01-01 -> created_at
        # @return [String]
        def converted_field_name
          FIELD_NAMES_TABLE[@token.field_name] || @token.field_name
        end
      end

      class AbsoluteDateExpression < BaseDateExpression
        # @note Matches to "YYYY", "YYYY-MM" and "YYYY-MM-DD"
        PATTERN = /\A
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

        def to_hash
          if @token.range_parameter
            range_block(@token.range_parameter => @token.range_query, "time_zone" => @token.time_zone)
          else
            range_block("gte" => beginning_of_range.to_s, "lt" => end_of_range.to_s, "time_zone" => @token.time_zone)
          end
        end

        private

        def range_block(field_block)
          {
            "range" => {
              converted_field_name => field_block.reject do |key, value|
                key == "time_zone" && value.nil?
              end,
            }
          }
        end

        # @return [Date]
        def end_of_range
          @end_of_range ||=
            case
            when match[:day]
              beginning_of_range + 1.day
            when match[:month]
              beginning_of_range + 1.month
            else
              beginning_of_range + 1.year
            end
        end

        # @return [Date]
        def beginning_of_range
          @beginning_of_range ||=
            case
            when match[:day]
              Date.new(match[:year].to_i, match[:month].to_i, match[:day].to_i)
            when match[:month]
              Date.new(match[:year].to_i, match[:month].to_i)
            else
              Date.new(match[:year].to_i)
            end
        end
      end

      class RelativeDateExpression < BaseDateExpression
        # @note Matches to "30d" and "30days"
        PATTERN = /\A
          (?<digit>\d+)
          (?<type>d|y|day|days|year|years)
        \z/x

        def to_hash
          if @token.range_parameter
            {
              "range" => {
                converted_field_name => {
                  @token.range_parameter => relative_range_with_hours,
                },
              },
            }
          else
            Nodes::NullNode.new.to_hash
          end
        end

        private

        def relative_range_with_hours
          @relative_range_with_hours ||=
            "now-" + convert_to_hours.to_s + "h"
        end

        # @return [Integer]
        def convert_to_hours
          case match[:type]
          when "d", "day", "days"
            match[:digit].to_i * 24
          when "y", "year", "years"
            match[:digit].to_i * 24 * 365
          else
            fail NotImplementedError
          end
        end
      end

      # @return [Hash]
      def to_hash
        if date
          date.to_hash
        else
          Nodes::NullNode.new.to_hash
        end
      end

      private

      # @return [BaseDateExpression, nil]
      def date
        @date ||= select_date
      end

      def select_date
        date = AbsoluteDateExpression.new(self)
        return date if date.match
        date = RelativeDateExpression.new(self)
        return date if date.match
        nil
      end

      # @note Override
      def has_invalid_term?
        !date
      end
    end
  end
end
