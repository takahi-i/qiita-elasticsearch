require "qiita/elasticsearch/date_token"
require "qiita/elasticsearch/filterable_token"
require "qiita/elasticsearch/hierarchal_token"
require "qiita/elasticsearch/matchable_token"
require "qiita/elasticsearch/int_token"

module Qiita
  module Elasticsearch
    class Tokenizer
      DEFAULT_DATE_FIELDS = []
      DEFAULT_DOWNCASED_FIELDS = []
      DEFAULT_FILTERABLE_FIELDS = []
      DEFAULT_HIERARCHAL_FIELDS = []
      DEFAULT_INT_FIELDS = []
      DEFAULT_MATCHABLE_FIELDS = []
      EXTRA_DATE_FIELDS = %w(created updated)
      EXTRA_FILTERABLE_FIELDS = %w(created is sort updated)

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
      # @param [Array<String>, nil] int_fields
      # @param [Array<String>, nil] matchable_fields
      # @param [String, nil] time_zone
      def initialize(date_fields: nil, downcased_fields: nil, filterable_fields: nil, hierarchal_fields: nil, int_fields: nil, matchable_fields: nil, time_zone: nil)
        @date_fields = (date_fields || DEFAULT_DATE_FIELDS) | EXTRA_DATE_FIELDS
        @downcased_fields = downcased_fields || DEFAULT_DOWNCASED_FIELDS
        @filterable_fields = (filterable_fields || DEFAULT_FILTERABLE_FIELDS) | EXTRA_FILTERABLE_FIELDS
        @hierarchal_fields = hierarchal_fields || DEFAULT_HIERARCHAL_FIELDS
        @int_fields = int_fields || DEFAULT_INT_FIELDS
        @matchable_fields = matchable_fields || DEFAULT_MATCHABLE_FIELDS
        @time_zone = time_zone
      end

      # @param [String] query_string Raw query string
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        query_string.scan(TOKEN_PATTERN).map do |token_string, minus, field_name, quoted_term, term|
          term ||= quoted_term
          if !field_name.nil? && !@filterable_fields.include?(field_name)
            term = "#{field_name}:#{term}"
            field_name = nil
          end
          token = token_class(field_name).new(
            downcased: @downcased_fields.include?(field_name),
            field_name: field_name,
            negative: !minus.nil?,
            quoted: !quoted_term.nil?,
            term: term,
            token_string: token_string,
          )
          token.matchable_fields = @matchable_fields if token.is_a?(MatchableToken)
          token.time_zone = @time_zone if token.is_a?(DateToken)
          token
        end
      end

      private

      def token_class(field_name)
        case
        when @date_fields.include?(field_name)
          DateToken
        when @int_fields.include?(field_name)
          IntToken
        when @hierarchal_fields.include?(field_name)
          HierarchalToken
        when @filterable_fields.include?(field_name)
          FilterableToken
        else
          MatchableToken
        end
      end
    end
  end
end
