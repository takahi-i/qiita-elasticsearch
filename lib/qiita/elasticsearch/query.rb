require "active_support/core_ext/object/try"
require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class Query
      DEFAULT_SORT = [{ "created_at" => "desc" }, "_score"]

      SORTS_TABLE = {
        "created-asc" => [{ "created_at" => "asc" }, "_score"],
        "created-desc" => [{ "created_at" => "desc" }, "_score"],
        "likes-asc" => [{ "lgtms" => "asc" }, "_score"],
        "likes-desc" => [{ "lgtms" => "desc" }, "_score"],
        "related-asc" => ["_score"],
        "related-desc" => [{ "_score" => "desc" }],
        "stocks-asc" => [{ "stocks" => "asc" }, "_score"],
        "stocks-desc" => [{ "stocks" => "desc" }, "_score"],
        "updated-asc" => [{ "updated_at" => "asc" }, "_score"],
        "updated-desc" => [{ "updated_at" => "desc" }, "_score"],
      }

      # @param [Array<Qiita::Elasticsearch::Token>] tokens
      # @param [Hash] query_builder_options For building new query from this query
      # @param [Hash] function_score_options options for scoring functions
      def initialize(tokens: nil, function_score_options: nil, query_builder_options: nil)
        @function_score_options = function_score_options
        @query_builder_options = query_builder_options
        @tokens = tokens
      end

      # @param [String] field_name
      # @param [String] term
      # @return [Qiita::Elasticsearch::Query]
      # @example query.append_field_token(field_name: "tag", term: "Ruby")
      def append_field_token(field_name: nil, term: nil)
        if has_field_token?(field_name: field_name, term: term)
          self
        else
          build_query([*@tokens, "#{field_name}:#{term}"].join(" "))
        end
      end

      # @param [String] field_name
      # @param [String] term
      # @return [Qiita::Elasticsearch::Query]
      # @example query.delete_field_token(field_name: "tag", term: "Ruby")
      def delete_field_token(field_name: nil, term: nil)
        build_query(
          @tokens.reject do |token|
            (field_name.nil? || token.field_name == field_name) && (term.nil? || token.term == term)
          end.join(" ")
        )
      end

      # @param [String] field_name
      # @param [false, nil, true] positive
      # @param [String] term
      # @example query.has_field_token?(field_name: "tag", term: "Ruby")
      def has_field_token?(field_name: nil, positive: nil, term: nil)
        @tokens.any? do |token|
          (field_name.nil? || token.field_name == field_name) && (term.nil? || token.term == term) &&
            (positive.nil? || positive && token.positive? || !positive && token.negative?)
        end
      end

      # @return [Hash] query property for request body for Elasticsearch
      def query
        if @function_score_options
          @function_score_options.merge!("query" => Nodes::OrSeparatableNode.new(@tokens).to_hash)
        else
          Nodes::OrSeparatableNode.new(@tokens).to_hash
        end
      end

      # @return [Array] sort property for request body for Elasticsearch
      def sort
        SORTS_TABLE[sort_term] || DEFAULT_SORT
      end

      def sort_term
        term = @tokens.select(&:sort?).last.try(:term)
        term if SORTS_TABLE.key?(term)
      end

      # @return [Hash] request body for Elasticsearch
      def to_hash
        {
          "query" => query,
          "sort" => sort,
        }
      end

      # @return [String] query string generated from its tokens
      def to_s
        @tokens.join(" ")
      end

      # @return [String, nil] last positive type name in query string
      def type
        @tokens.select(&:type?).select(&:positive?).last.try(:type)
      end

      # @param [String] field_name
      # @param [String] term
      # @return [Qiita::Elasticsearch::Query]
      # @example query.update_field_token(field_name: "tag", term: "Ruby")
      def update_field_token(field_name: nil, term: nil)
        build_query(
          @tokens.reject do |token|
            token.field_name == field_name
          end.map(&:to_s).push("#{field_name}:#{term}").join(" ")
        )
      end

      private

      # Build a new query from query string
      # @param [String] query_string
      # @return [Qiita::Elasticsearch::Query]
      # @example build_query("test tag:Ruby")
      def build_query(query_string)
        query_builder.build(query_string)
      end

      # @return [Qiita::Elasticsearch::QueryBuilder]
      def query_builder
        QueryBuilder.new(query_builder_options)
      end

      # @return [Hash]
      def query_builder_options
        @query_builder_options || {}
      end
    end
  end
end
