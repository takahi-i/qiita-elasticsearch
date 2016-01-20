require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class FilterableToken < Token
      EDIT_PERMISSION_COEDITING = 2

      # @return [Hash]
      def to_hash
        case
        when archived?
          {
            "term" => {
              "archived" => true,
            },
          }
        when code?
          {
            "query" => {
              "match_phrase" => {
                "code" => downcased_term,
              },
            },
          }
        when coediting?
          {
            "term" => {
              "edit_permission" => EDIT_PERMISSION_COEDITING,
            },
          }
        when group?
          {
            "terms" => {
              "execution" => "or",
              "group_id" => group_ids,
            }
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

      def archived?
        field_name == "is" && term == "archived"
      end

      def article_type?
        field_name == "is" && term == "article"
      end

      def coediting?
        field_name == "is" && term == "coediting"
      end

      def code?
        field_name == "code"
      end

      # @private
      # @note This is for group filter query (e.g. "group:dev", "group:dev,sales")
      # @return [Array<Integer>]
      def group_ids
        groups.pluck(:id)
      end

      # @private
      # @return [Array<String>]
      def group_url_names
        if group?
          term.split(",")
        else
          []
        end
      end

      def group?
        field_name == "group"
      end

      # @private
      # @note This method depends on the existence of `Group` ActiveRecord model class.
      # @return [ActiveRecord::Relation]
      def groups
        ::Group.where(url_name: group_url_names)
      end

      def project_type?
        field_name == "is" && term == "project"
      end
    end
  end
end
