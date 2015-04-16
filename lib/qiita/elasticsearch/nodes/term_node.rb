module Qiita
  module Elasticsearch
    module Nodes
      class TermNode
        DEFAULT_HIERARCHAL_FIELDS = []
        DEFAULT_RANGE_FIELDS = []

        # @param [Qiita::Elasticsearch::Token] token
        # @param [Array<String>, nil] hierarchal_fields
        # @param [Array<String>, nil] range_fields
        def initialize(token, hierarchal_fields: nil, range_fields: nil)
          @hierarchal_fields = hierarchal_fields
          @range_fields = range_fields
          @token = token
        end

        # @return [Hash]
        def to_hash
          case
          when has_hierarchal_token?
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
          when has_range_token?
            {
              "range" => {
                @token.field_name => {
                  @token.range_parameter => @token.range_query,
                },
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

        def has_range_token?
          range_fields.include?(@token.field_name) && @token.range_parameter
        end

        def range_fields
          @range_fields || DEFAULT_RANGE_FIELDS
        end
      end
    end
  end
end
