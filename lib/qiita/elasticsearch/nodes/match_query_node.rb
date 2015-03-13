module Qiita
  module Elasticsearch
    module Nodes
      class MatchQueryNode
        # @param [String] term
        # @param [Array<String>, nil] fields Available field names
        def initialize(term, fields: nil)
          @fields = fields
          @term = term
        end

        # @return [Hash] match query or multi_match query
        def to_hash
          if @fields.nil?
            {
              "match" => {
                "_all" => @term,
              }
            }
          else
            {
              "multi_match" => {
                "fields" => @fields,
                "query" => @term,
              },
            }
          end
        end
      end
    end
  end
end
