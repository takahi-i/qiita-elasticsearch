require "qiita/elasticsearch/query"

RSpec.describe Qiita::Elasticsearch::Query do
  let(:query) do
    query_builder.build(query_string)
  end

  let(:query_builder) do
    Qiita::Elasticsearch::QueryBuilder.new(filterable_fields: ["tag"])
  end

  let(:query_string) do
    "test tag:Rails"
  end

  describe "#append_field_token" do
    subject do
      query.append_field_token(field_name: "tag", term: "Ruby").to_hash
    end

    it "appends given field token and returns a new query" do
      is_expected.to eq(
        "query" => {
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must" => [
                  {
                    "term" => {
                      "tag" => "Rails",
                    },
                  },
                  {
                    "term" => {
                      "tag" => "Ruby",
                    },
                  },
                ],
              },
            },
            "query" => {
              "match" => {
                "_all" => "test",
              },
            },
          },
        },
        "sort" => [{ "created_at" => "desc" }, "_score"],
      )
    end
  end

  describe "#delete_field_token" do
    subject do
      query.delete_field_token(field_name: "tag", term: "Rails").to_hash
    end

    it "deletes given field token and returns a new query" do
      is_expected.to eq(
        "query" => {
          "match" => {
            "_all" => "test",
          },
        },
        "sort" => [{ "created_at" => "desc" }, "_score"],
      )
    end
  end

  describe "#has_field_token?" do
    subject do
      query.has_field_token?(field_name: field_name, positive: positive, term: term)
    end

    let(:field_name) do
      "tag"
    end

    let(:positive) do
      nil
    end

    let(:term) do
      "Rails"
    end

    context "with same field name and term" do
      it { is_expected.to be true }
    end

    context "with different field name" do
      let(:field_name) do
        "user"
      end

      it { is_expected.to be false }
    end

    context "with different term" do
      let(:field_name) do
        "Ruby"
      end

      it { is_expected.to be false }
    end

    context "without field_name argument" do
      let(:field_name) do
        nil
      end

      it { is_expected.to be true }
    end

    context "without term argument" do
      let(:term) do
        nil
      end

      it { is_expected.to be true }
    end

    context "with positive true with positive token" do
      let(:positive) do
        true
      end

      it { is_expected.to be true }
    end

    context "with positive false with positive token" do
      let(:positive) do
        false
      end

      it { is_expected.to be false }
    end

    context "with positive true with negative token" do
      let(:positive) do
        true
      end

      let(:query_string) do
        "-tag:Rails"
      end

      it { is_expected.to be false }
    end

    context "with positive false with negative token" do
      let(:positive) do
        false
      end

      let(:query_string) do
        "-tag:Rails"
      end

      it { is_expected.to be true }
    end
  end

  describe "#to_s" do
    subject do
      query.to_s
    end

    it "returns query string generated from its tokens" do
      is_expected.to eq query_string
    end
  end

  describe "#type" do
    subject do
      query.type
    end

    context "without any type token" do
      it { is_expected.to be_nil }
    end

    context "with -is:project" do
      let(:query_string) do
        "-is:project"
      end

      it { is_expected.to be_nil }
    end

    context "with is:project" do
      let(:query_string) do
        "is:project"
      end

      it { is_expected.to eq "project" }
    end

    context "with is:article" do
      let(:query_string) do
        "is:article"
      end

      it { is_expected.to eq "team_item" }
    end

    context "with is:article is:project" do
      let(:query_string) do
        "is:article is:project"
      end

      it { is_expected.to eq "project" }
    end

    context "with is:article -is:project" do
      let(:query_string) do
        "is:article -is:project"
      end

      it { is_expected.to eq "team_item" }
    end
  end

  describe "#update_field_token" do
    subject do
      query.update_field_token(field_name: "tag", term: "Ruby").to_hash
    end

    it "updates field tokens that match with given field name and term" do
      is_expected.to eq(
        "query" => {
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "Ruby",
              },
            },
            "query" => {
              "match" => {
                "_all" => "test",
              },
            },
          },
        },
        "sort" => [{ "created_at" => "desc" }, "_score"],
      )
    end
  end
end
