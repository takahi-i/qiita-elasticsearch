module Qiita
  module Elasticsearch
    module SpecHelper
      # @return [Hash]
      def build_combined_match_query(fields: ["_all"], query: nil)
        {
          "bool" => {
            "should" => [
              {
                "multi_match" => {
                  "boost" => 1,
                  "fields" => fields,
                  "query" => query,
                  "type" => "phrase",
                },
              },
              {
                "multi_match" => {
                  "boost" => Qiita::Elasticsearch::MatchableToken::RELATIVE_BEST_FIELDS_QUERY_WEIGHT,
                  "fields" => fields,
                  "query" => query,
                  "type" => "best_fields",
                },
              },
            ]
          },
        }
      end
    end
  end
end
