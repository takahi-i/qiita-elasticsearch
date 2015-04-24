require "qiita/elasticsearch/token"

RSpec.describe Qiita::Elasticsearch::Token do
  describe "#to_s" do
    let(:token) do
      tokenizer.tokenize(query_string).first
    end

    let(:tokenizer) do
      Qiita::Elasticsearch::Tokenizer.new(filterable_fields: ["tag"])
    end

    let(:query_string) do
      "tag:Rails"
    end

    it "returns original token string" do
      expect(token.to_s).to eq query_string
    end
  end
end
