require "qiita/elasticsearch/concerns/range_operand_includable"
require "qiita/elasticsearch/errors"
require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class IntToken < Token
      include Concerns::RangeOperandIncludable

      INT_PATTERN = /\A\d+\z/

      # @return [Hash]
      # @raise [InvalidQuery]
      def to_hash
        if range_parameter && INT_PATTERN =~ range_query
          {
            "range" => {
              @field_name => {
                range_parameter => range_query.to_i,
              },
            },
          }
        elsif INT_PATTERN =~ @term
          {
            "term" => {
              @field_name => @term.to_i,
            },
          }
        else
          fail InvalidQuery
        end
      end
    end
  end
end
