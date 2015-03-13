require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
  describe "#build" do
    subject do
      query_builder.build(query_string)
    end

    let(:fields) do
    end

    let(:filterable_fields) do
    end

    let(:properties) do
      {
        fields: fields,
        filterable_fields: filterable_fields,
      }
    end

    let(:query_builder) do
      described_class.new(properties)
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

    context "with double-quoted positive token" do
      let(:query_string) do
        '"a"'
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

    context "with fields property" do
      let(:fields) do
        ["tag"]
      end

      let(:query_string) do
        "a"
      end

      it do
        is_expected.to eq(
          "multi_match" => {
            "fields" => fields,
            "query" => "a",
          },
        )
      end
    end

    context "with filterable_fields property and token including field name" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "tag:a"
      end

      it do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "a",
              },
            },
            "query" => {
              "match_all" => {},
            },
          },
        )
      end
    end

    context "with token including unknown field name" do
      let(:query_string) do
        "tag:a"
      end

      it do
        is_expected.to eq(
          "match" => {
            "_all" => "tag:a",
          },
        )
      end
    end

    context "with normal token and another token including known field name" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "a tag:b"
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
                "filtered" => {
                  "filter" => {
                    "term" => {
                      "tag" => "b",
                    },
                  },
                  "query" => {
                    "match_all" => {},
                  },
                },
              },
            ],
          }
        )
      end
    end
  end
end
