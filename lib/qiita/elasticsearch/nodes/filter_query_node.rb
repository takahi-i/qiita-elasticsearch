module Qiita
  module Elasticsearch
    module Nodes
      class FilterQueryNode
        DEFAULT_HIERARCHAL_FIELDS = []

        # @param [Qiita::Elasticsearch::Token] token
        def initialize(token, hierarchal_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @token = token
        end

        # @return [Hash]
        def to_hash
          if has_hierarchal_token?
            {
              "filtered" => {
                "filter" => {
                  "bool" => {
                    "should" => [
                      {
                        "prefix" => {
                          @token.field_name => @token.downcased_term + "/",
                        },
                      },
                      {
                        "term" => {
                          @token.field_name => @token.downcased_term,
                        },
                      },
                    ],
                  },
                },
                "query" => {
                  "match_all" => {},
                },
              },
            }
          else
            {
              "filtered" => {
                "filter" => {
                  "term" => {
                    @token.field_name => @token.downcased_term,
                  },
                },
                "query" => {
                  "match_all" => {},
                },
              },
            }
          end
        end

        private

        def has_hierarchal_token?
          hierarchal_fields.include?(@token.field_name)
        end

        def hierarchal_fields
          @hierarchal_fields || DEFAULT_HIERARCHAL_FIELDS
        end
      end
    end
  end
end
