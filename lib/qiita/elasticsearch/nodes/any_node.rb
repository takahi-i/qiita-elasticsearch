module Qiita
  module Elasticsearch
    module Nodes
      class AnyNode
        def to_hash
          { "match_all" => {} }
        end
      end
    end
  end
end
