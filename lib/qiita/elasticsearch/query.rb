require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/tokenizer"

module Qiita
  module Elasticsearch
    class Query
      # @param [Array<Qiita::Elasticsearch::Token>] tokens
      # @param [Hash] query_builder_options For building new query from this query
      def initialize(tokens, query_builder_options = nil)
        @query_builder_options = query_builder_options
        @tokens = tokens
      end

      # @param [String] field_name
      # @param [String] term
      # @return [Qiita::Elasticsearch::Query]
      # @example query.append_field_token(field_name: "tag", term: "Ruby")
      def append_field_token(field_name: nil, term: nil)
        build_query([*@tokens, "#{field_name}:#{term}"].join(" "))
      end

      # @param [String] field_name
      # @param [String] term
      # @return [Qiita::Elasticsearch::Query]
      # @example query.delete_field_token(field_name: "tag", term: "Ruby")
      def delete_field_token(field_name: nil, term: nil)
        build_query(
          @tokens.reject do |token|
            token.field_name == field_name && token.term == term
          end.join(" ")
        )
      end

      # @param [String] field_name
      # @param [String] term
      # @example query.has_field_token?(field_name: "tag", term: "Ruby")
      def has_field_token?(field_name: nil, term: nil)
        @tokens.any? do |token|
          token.field_name == field_name && token.term == term
        end
      end

      # @return [Hash]
      # @example query.to_hash
      def to_hash
        if has_empty_tokens?
          Nodes::NullNode.new.to_hash
        else
          Nodes::OrSeparatableNode.new(@tokens).to_hash
        end
      end

      # @return [String] query string generated from its tokens
      def to_s
        @tokens.join(" ")
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

      def has_empty_tokens?
        @tokens.size.zero?
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
