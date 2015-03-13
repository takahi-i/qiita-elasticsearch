module Qiita
  module Elasticsearch
    module Nodes
      class MatchQueryNode
        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] fields Available field names
        def initialize(token, fields: nil)
          @fields = fields
          @token = token
        end

        # @return [Hash] match query or multi_match query
        def to_hash
          if @fields.nil?
            {
              "match" => {
                "_all" => @token.term,
              }
            }
          else
            {
              "multi_match" => {
                "fields" => @fields,
                "query" => @token.term,
              },
            }
          end
        end
      end
    end
  end
end
