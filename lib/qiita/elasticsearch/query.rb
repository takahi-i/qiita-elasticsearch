module Qiita
  module Elasticsearch
    class Query
      # @param [Array<Qiita::Elasticsearch::Token>]
      def initialize(tokens)
        @tokens = tokens
      end

      # @todo
      # @return [Hash]
      def to_hash
        {
          "match" => {
            "_all" => @tokens.first.to_s,
          },
        }
      end
    end
  end
end
