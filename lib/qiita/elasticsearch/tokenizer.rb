require "qiita/elasticsearch/date_token"
require "qiita/elasticsearch/filterable_token"
require "qiita/elasticsearch/hierarchal_token"
require "qiita/elasticsearch/matchable_token"
require "qiita/elasticsearch/range_token"

module Qiita
  module Elasticsearch
    class Tokenizer
      DEFAULT_DATE_FIELDS = []
      DEFAULT_DOWNCASED_FIELDS = []
      DEFAULT_FILTERABLE_FIELDS = []
      DEFAULT_HIERARCHAL_FIELDS = []
      DEFAULT_RANGE_FIELDS = []

      TOKEN_PATTERN = /
        (?<token_string>
          (?<minus>-)?
          (?:(?<field_name>\w+):)?
          (?:
            (?:"(?<quoted_term>.*?)(?<!\\)")
            |
            (?<term>\S+)
          )
        )
      /x

      # @param [Array<String>, nil] date_fields
      # @param [Array<String>, nil] downcased_fields
      # @param [Array<String>, nil] filterable_fields
      # @param [Array<String>, nil] hierarchal_fields
      # @param [Array<String>, nil] matchable_fields
      # @param [Array<String>, nil] range_fields
      def initialize(date_fields: nil, downcased_fields: nil, filterable_fields: nil, hierarchal_fields: nil, matchable_fields: nil, range_fields: nil)
        @date_fields = date_fields
        @downcased_fields = downcased_fields
        @filterable_fields = filterable_fields
        @hierarchal_fields = hierarchal_fields
        @matchable_fields = matchable_fields
        @range_fields = range_fields
      end

      # @param [String] query_string Raw query string
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        query_string.scan(TOKEN_PATTERN).map do |token_string, minus, field_name, quoted_term, term|
          term ||= quoted_term
          if !field_name.nil? && !filterable_fields.include?(field_name)
            term = "#{field_name}:#{term}"
            field_name = nil
          end
          token = token_class(field_name).new(
            downcased: downcased_fields.include?(field_name),
            field_name: field_name,
            minus: minus,
            quoted: !quoted_term.nil?,
            term: term,
            token_string: token_string,
          )
          token.matchable_fields = @matchable_fields if token.is_a?(MatchableToken)
          token
        end
      end

      private

      def date_fields
        @date_fields || DEFAULT_DATE_FIELDS
      end

      def downcased_fields
        @downcased_fields || DEFAULT_DOWNCASED_FIELDS
      end

      def filterable_fields
        @filterable_fields || DEFAULT_FILTERABLE_FIELDS
      end

      def hierarchal_fields
        @hierarchal_fields || DEFAULT_HIERARCHAL_FIELDS
      end

      def range_fields
        @range_fields || DEFAULT_RANGE_FIELDS
      end

      def token_class(field_name)
        case
        when date_fields.include?(field_name)
          DateToken
        when range_fields.include?(field_name)
          RangeToken
        when hierarchal_fields.include?(field_name)
          HierarchalToken
        when filterable_fields.include?(field_name)
          FilterableToken
        else
          MatchableToken
        end
      end
    end
  end
end
