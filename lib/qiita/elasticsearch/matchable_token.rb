require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class MatchableToken < Token
      RELATIVE_BEST_FIELDS_QUERY_WEIGHT = 0.5

      attr_writer :matchable_fields

      # @return [Hash]
      def to_hash
        if quoted?
          build_multi_match_query(type: "phrase")
        else
          {
            "bool" => {
              "should" => [
                build_multi_match_query(type: "phrase"),
                build_multi_match_query(type: "best_fields", boost: RELATIVE_BEST_FIELDS_QUERY_WEIGHT),
              ],
            },
          }
        end
      end

      private

      # @return [Hash]
      def build_multi_match_query(type: nil, boost: 1)
        {
          "multi_match" => {
            "boost" => boost,
            "fields" => @matchable_fields || ["_all"],
            "query" => @term,
            "type" => type,
          },
        }
      end
    end
  end
end
