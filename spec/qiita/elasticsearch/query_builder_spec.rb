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

    context "with empty string" do
      let(:query_string) do
        ""
      end

      it "returns null query that matches with nothing" do
        is_expected.to eq(
          "query" => {
            "ids" => {
              "values" => [],
            },
          },
        )
      end
    end

    context "with no token" do
      let(:query_string) do
        " "
      end

      it "returns null query" do
        is_expected.to eq query_builder.build("")
      end
    end

    context "with positive token" do
      let(:query_string) do
        "a"
      end

      it do
        is_expected.to eq(
          "bool" => {
            "must" => [],
            "must_not" => [],
            "should" => [
              "match" => {
                "_all" => "a",
              },
            ],
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
          "bool" => {
            "must" => [],
            "must_not" => [],
            "should" => [
              "match" => {
                "_all" => "a",
              },
            ],
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
            "must" => [],
            "must_not" => [
              "match" => {
                "_all" => "a",
              },
            ],
            "should" => [],
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
            "must" => [],
            "must_not" => [],
            "should" => [
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
            "must" => [],
            "must_not" => [
              "match" => {
                "_all" => "b",
              },
            ],
            "should" => [
              "match" => {
                "_all" => "a",
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
          "bool" => {
            "must" => [],
            "must_not" => [],
            "should" => [
              "multi_match" => {
                "fields" => fields,
                "query" => "a",
              },
            ],
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
          "bool" => {
            "must" => [
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
            ],
            "must_not" => [],
            "should" => [],
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
          "bool" => {
            "must" => [],
            "must_not" => [],
            "should" => [
              "match" => {
                "_all" => "tag:a",
              },
            ],
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
            "must_not" => [],
            "should" => [
              {
                "match" => {
                  "_all" => "a",
                },
              },
            ],
          },
        )
      end
    end

    context "with tokens connected with OR token" do
      let(:query_string) do
        "a OR b"
      end

      it do
        is_expected.to eq(
          "bool" => {
            "should" => [
              {
                "bool" => {
                  "must" => [],
                  "must_not" => [],
                  "should" => [
                    {
                      "match" => {
                        "_all" => "a",
                      },
                    },
                  ],
                },
              },
              {
                "bool" => {
                  "must" => [],
                  "must_not" => [],
                  "should" => [
                    {
                      "match" => {
                        "_all" => "b",
                      },
                    },
                  ],
                },
              },
            ],
          },
        )
      end
    end

    context "with only OR token" do
      let(:query_string) do
        "OR"
      end

      it "returns null query" do
        is_expected.to eq query_builder.build("")
      end
    end

    context "with malformed OR token" do
      let(:query_string) do
        "OR a"
      end

      it "ignores OR token" do
        is_expected.to eq query_builder.build("a")
      end
    end

    context "with downcased OR token" do
      let(:query_string) do
        "a or b"
      end

      it "treats both or and OR as OR token" do
        is_expected.to eq query_builder.build("a OR b")
      end
    end
  end
end
