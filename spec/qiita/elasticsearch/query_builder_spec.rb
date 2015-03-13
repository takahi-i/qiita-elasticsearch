require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
  describe ".new" do
    it { is_expected.to be_a described_class }
  end

  describe "#build" do
    subject do
      query_builder.build(query_string)
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

    it { is_expected.to be_a Qiita::Elasticsearch::Query }
  end
end
