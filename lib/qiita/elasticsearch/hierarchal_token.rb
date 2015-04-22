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
                  @field_name => proper_cased_term + "/",
                },
              },
              {
                "term" => {
                  @field_name => proper_cased_term,
                },
              },
            ],
          },
        }
      end
    end
  end
end
