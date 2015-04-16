require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class HierarchalToken < Token
      # @return [Hash]
      def to_hash
        {
          "bool" => {
            "should" => [
              {
                "prefix" => {
                  @field_name => downcased_term + "/",
                },
              },
              {
                "term" => {
                  @field_name => downcased_term,
                },
              },
            ],
          },
        }
      end
    end
  end
end
