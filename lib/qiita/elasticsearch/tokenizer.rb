require "qiita/elasticsearch/token"

module Qiita
  module Elasticsearch
    class Tokenizer
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

      # @param [String] query_string Raw query string given from search user.
      # @return [Array<Qiita::Elasticsearch::Token>]
      def tokenize(query_string)
        query_string.scan(TOKEN_PATTERN).map do |token_string, minus, field_name, quoted_term, term|
          Token.new(
            field_name: field_name,
            minus: minus,
            quoted_term: quoted_term,
            term: term,
            token_string: token_string,
          )
        end
      end
    end
  end
end
