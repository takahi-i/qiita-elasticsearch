require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class FilterableToken < Token
      EDIT_PERMISSION_COEDITING = 2

      # @return [Hash]
      def to_hash
        if field_name == "is" && term == "coediting"
          {
            "term" => {
              "edit_permission" => EDIT_PERMISSION_COEDITING,
            },
          }
        else
          {
            "term" => {
              @field_name => proper_cased_term,
            },
          }
        end
      end
    end
  end
end
