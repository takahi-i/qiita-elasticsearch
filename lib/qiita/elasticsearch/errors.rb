module Qiita
  module Elasticsearch
    # @note Custom error class for rescuing from all Qiita::Elasticsearch errors.
    class Error < StandardError
    end

    class InvalidQuery < Error
    end
  end
end
