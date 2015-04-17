require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class MatchableToken < Token
      attr_writer :matchable_fields

      # @return [Hash]
      def to_hash
        if @matchable_fields.nil?
          {
            quoted? ? "match_phrase" : "match" => {
              "_all" => @term,
            }
          }
        else
          hash = {
            "multi_match" => {
              "fields" => @matchable_fields,
              "query" => @term,
            },
          }
          hash["multi_match"]["type"] = "phrase" if quoted?
          hash
        end
      end
    end
  end
end
