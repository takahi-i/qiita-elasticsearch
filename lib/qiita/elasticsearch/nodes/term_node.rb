module Qiita
  module Elasticsearch
    module Nodes
      class TermNode
        DEFAULT_HIERARCHAL_FIELDS = []

        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] hierarchal_fields
        def initialize(token, hierarchal_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @token = token
        end

        # @return [Hash]
        def to_hash
          if has_hierarchal_token?
            {
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
            }
          else
            {
              "term" => {
                @token.field_name => @token.downcased_term,
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
