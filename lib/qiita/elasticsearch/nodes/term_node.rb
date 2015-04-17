module Qiita
  module Elasticsearch
    module Nodes
      class TermNode
        # @param [Qiita::Elasticsearch::Token] token
        def initialize(token)
          @token = token
        end

        # @return [Hash]
        def to_hash
          @token.to_hash
        end
      end
    end
  end
end
