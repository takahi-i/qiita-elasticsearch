require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
  describe ".new" do
    it { is_expected.to be_a described_class }
  end

  describe "#build" do
    subject do
      query_builder.build(query_string).to_hash
    end

    let(:constructor_parameters) do
      {}
    end

    let(:query_builder) do
      described_class.new(constructor_parameters)
    end

    let(:query_string) do
      "a"
    end

    context "with simple query string" do
      it do
        is_expected.to eq(
          "match" => {
            "_all" => query_string,
          },
        )
      end
    end
  end
end
