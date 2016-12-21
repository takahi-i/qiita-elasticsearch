require "qiita/elasticsearch/nodes/null_node"
require "qiita/elasticsearch/nodes/or_separatable_node"
require "qiita/elasticsearch/query"

module Qiita
  module Elasticsearch
    class QueryBuilder
      # @param [Array<String>, nil] all_fields
      # @param [Array<String>, nil] date_fields
      # @param [Array<String>, nil] downcased_fields
      # @param [Array<String>, nil] filterable_fields
      # @param [Array<String>, nil] hierarchal_fields
      # @param [Array<String>, nil] int_fields
      # @param [Array<String>, nil] default_fields
      # @param [String, nil] time_zone
      # @param [Hash, nil] matchable_options
      # @param [Hash, nil] field_mapping for field aliasing
      # @param [Array, nil] function_score_options
      def initialize(all_fields: nil, date_fields: nil, downcased_fields: nil, hierarchal_fields: nil,
                     filterable_fields: nil, int_fields: nil, default_fields: nil, time_zone: nil,
                     matchable_options: nil, field_mapping: nil, function_score_options: nil)
        @all_fields = all_fields
        @date_fields = date_fields
        @downcased_fields = downcased_fields
        @filterable_fields = filterable_fields
        @hierarchal_fields = hierarchal_fields
        @int_fields = int_fields
        @default_fields = default_fields
        @time_zone = time_zone
        @matchable_options = matchable_options
        @field_mapping = field_mapping
        @function_score_options = function_score_options
      end

      # @param [String] query_string Raw query string
      # @return [Qiita::Elasticsearch::Query]
      def build(query_string)
        Query.new(
          tokens:  tokenizer.tokenize(query_string),
          function_score_options: @function_score_options,
          query_builder_options: {
            downcased_fields: @downcased_fields,
            filterable_fields: @filterable_fields,
            hierarchal_fields: @hierarchal_fields,
            int_fields: @int_fields,
            default_fields: @default_fields,
            time_zone: @time_zone
          }
        )
      end

      private

      def tokenizer
        @tokenizer ||= Tokenizer.new(
          all_fields: @all_fields,
          date_fields: @date_fields,
          downcased_fields: @downcased_fields,
          filterable_fields: @filterable_fields,
          hierarchal_fields: @hierarchal_fields,
          int_fields: @int_fields,
          default_fields: @default_fields,
          time_zone: @time_zone,
          matchable_options: @matchable_options,
          field_mapping: @field_mapping
        )
      end
    end
  end
end
