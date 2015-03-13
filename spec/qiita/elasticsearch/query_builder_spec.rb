require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
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

    context "with positive token" do
      let(:query_string) do
        "a"
      end

      it do
        is_expected.to eq(
          "match" => {
            "_all" => "a",
          },
        )
      end
    end

    context "with negative token" do
      let(:query_string) do
        "-a"
      end

      it do
        is_expected.to eq(
          "bool" => {
            "must_not" => [
              "match" => {
                "_all" => "a",
              },
            ],
          },
        )
      end
    end

    context "with multiple positive tokens" do
      let(:query_string) do
        "a b"
      end

      it do
        is_expected.to eq(
          "bool" => {
            "must" => [
              {
                "match" => {
                  "_all" => "a",
                },
              },
              {
                "match" => {
                  "_all" => "b",
                },
              },
            ],
          },
        )
      end
    end

    context "with positive token and negative token" do
      let(:query_string) do
        "a -b"
      end

      it do
        is_expected.to eq(
          "bool" => {
            "must" => [
              "match" => {
                "_all" => "a",
              },
            ],
            "must_not" => [
              "match" => {
                "_all" => "b",
              },
            ],
          },
        )
      end
    end
  end
end
