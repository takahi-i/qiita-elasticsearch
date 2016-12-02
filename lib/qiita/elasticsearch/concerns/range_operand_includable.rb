require "active_support/concern"

module Qiita
  module Elasticsearch
    module Concerns
      module RangeOperandIncludable
        extend ActiveSupport::Concern

        RANGE_TERM_REGEXP = /\A(?<operand>\<=|\<|\>=|\>)(?<query>.*)\z/

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
end
