module Qiita
  module Elasticsearch
    module Nodes
      class NullNode
        def to_hash
          {
            "query" => {
              "ids" => {
                "values" => [],
              },
            },
          }
        end
      end
    end
  end
end
