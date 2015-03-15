module Qiita
  module Elasticsearch
    module Nodes
      class MatchQueryNode
        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] matchable_fields
        def initialize(token, matchable_fields: nil)
          @matchable_fields = matchable_fields
          @token = token
        end

        # @return [Hash] match query or multi_match query
        def to_hash
          if @matchable_fields.nil?
            {
              "match" => {
                "_all" => @token.term,
              }
            }
          else
            {
              "multi_match" => {
                "fields" => @matchable_fields,
                "query" => @token.term,
              },
            }
          end
        end
      end
    end
  end
end
