module Qiita
  module Elasticsearch
    module Nodes
      class FilterQueryNode
        # @param [Qiita::Elasticsearch::Token] token
        def initialize(token)
          @token = token
        end

        # @return [Hash]
        def to_hash
          {
            "filtered" => {
              "filter" => {
                "term" => {
                  @token.field_name => @token.term,
                },
              },
              "query" => {
                "match_all" => {},
              },
            },
          }
        end
      end
    end
  end
end
