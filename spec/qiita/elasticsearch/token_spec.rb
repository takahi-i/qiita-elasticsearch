require "qiita/elasticsearch/token"

RSpec.describe Qiita::Elasticsearch::Token do
  let(:token) do
    tokenizer.tokenize(query_string).first
  end

  let(:tokenizer) do
  end

  let(:query_string) do
  end

  describe "#to_s" do
    let(:tokenizer) do
      Qiita::Elasticsearch::Tokenizer.new(filterable_fields: ["tag"])
    end

    context "with tag" do
      let(:query_string) do
        "tag:Rails"
      end

      it "returns original token string" do
        expect(token.to_s).to eq query_string
      end
    end
  end

  describe "#has_invalid_term?" do
    subject { token.send(:has_invalid_term?) }

    context "and DateToken" do
      let(:tokenizer) do
        Qiita::Elasticsearch::Tokenizer.new(date_fields: ["created_at"])
      end

      context "with invalid term" do
        let(:query_string) do
          "created:invalid"
        end

        it { should be true }
      end

      context "with absolute date" do
        let(:query_string) do
          "created:>2015-04-01"
        end

        it { should be false }
      end

      context "with relative date" do
        let(:query_string) do
          "created:>10d"
        end

        it { should be false }
      end
    end
  end
end
