require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class Tokenizer
      # @todo The current returned-value is dummy object.
      # @param [String] query_string Raw query string given from search user.
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        [Token.new]
      end
    end
  end
end
