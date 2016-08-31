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
      DEFAULT_DEFAULT_FIELDS = []
      EXTRA_DATE_FIELDS = %w(created updated)
      EXTRA_FILTERABLE_FIELDS = %w(created is sort updated)

      TOKEN_PATTERN = /
        (?<token_string>
          (?<minus>-)?
          (?:
            (?:
              (?<field_name>\w+):
              |
              (?<field_symbol>[@\#])
            )
          )?
          (?:
            (?:"(?<quoted_term>.*?)(?<!\\)")
            |
            (?<term>\S+)
          )
        )
      /x

      # @param [Array<String>, nil] all_fields
      # @param [Array<String>, nil] date_fields
      # @param [Array<String>, nil] downcased_fields
      # @param [Array<String>, nil] filterable_fields
      # @param [Array<String>, nil] hierarchal_fields
      # @param [Array<String>, nil] int_fields
      # @param [Array<String>, nil] default_fields
      # @param [String, nil] time_zone
      def initialize(all_fields: nil, date_fields: nil, downcased_fields: nil, filterable_fields: nil, hierarchal_fields: nil, int_fields: nil, default_fields: nil, time_zone: nil)
        @date_fields = (date_fields || DEFAULT_DATE_FIELDS) | EXTRA_DATE_FIELDS
        @downcased_fields = downcased_fields || DEFAULT_DOWNCASED_FIELDS
        @filterable_fields = (filterable_fields || DEFAULT_FILTERABLE_FIELDS) | EXTRA_FILTERABLE_FIELDS
        @hierarchal_fields = hierarchal_fields || DEFAULT_HIERARCHAL_FIELDS
        @int_fields = int_fields || DEFAULT_INT_FIELDS
        @default_fields = default_fields || DEFAULT_DEFAULT_FIELDS
        @all_fields = aggregate_all_fields(all_fields)
        @time_zone = time_zone
      end

      # @param [String] query_string Raw query string
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        query_string.scan(TOKEN_PATTERN).map do |token_string, minus, field_name, field_symbol, quoted_term, term| # rubocop:disable Metrics/ParameterLists
          term ||= quoted_term

          case field_symbol
          when "@"
            field_name = "user"
          when "#"
            field_name = "tag"
          end

          if !field_name.nil? && !@all_fields.include?(field_name)
            term = "#{field_name}:#{term}"
            field_name = nil
          end
          token = token_class(field_name).new(
            downcased: @downcased_fields.include?(field_name),
            field_name: field_name,
            negative: !minus.nil?,
            quoted: !quoted_term.nil?,
            filter: @filterable_fields.include?(field_name),
            term: term,
            token_string: token_string,
          )
          token.default_fields = @default_fields if token.is_a?(MatchableToken)
          token.time_zone = @time_zone if token.is_a?(DateToken)
          token
        end
      end

      private

      def aggregate_all_fields(base)
        fields = [
          base,
          @date_fields,
          @downcased_fields,
          @filterable_fields,
          @hierarchal_fields,
          @int_fields,
          @default_fields
        ].flatten.compact

        fields.map { |field| field.sub(/\^\d+\z/, "") }.uniq
      end

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
