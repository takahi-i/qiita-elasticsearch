require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class FilterableToken < Token
      EDIT_PERMISSION_COEDITING = 2

      # @return [Hash]
      def to_hash
        case
        when coediting?
          {
            "term" => {
              "edit_permission" => EDIT_PERMISSION_COEDITING,
            },
          }
        when type?
          {
            "type" => {
              "value" => type,
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

      # @return [String] actual type name on Elasticsearch
      def type
        if article_type?
          "team_item"
        else
          term
        end
      end

      # @note Override
      def type?
        article_type? || project_type?
      end

      private

      def article_type?
        field_name == "is" && term == "article"
      end

      def coediting?
        field_name == "is" && term == "coediting"
      end

      def project_type?
        field_name == "is" && term == "project"
      end
    end
  end
end
