require "qiita/elasticsearch/concerns/range_operand_includable"
require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class IntToken < Token
      include Concerns::RangeOperandIncludable

      # @return [Hash]
      def to_hash
        if range_parameter
          {
            "range" => {
              @field_name => {
                range_parameter => range_query.to_i,
              },
            },
          }
        else
          {
            "term" => {
              @field_name => downcased_term.to_i,
            },
          }
        end
      end
    end
  end
end
