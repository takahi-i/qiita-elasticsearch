require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
  describe "#build" do
    subject do
      query_builder.build(query_string)
    end

    let(:downcased_fields) do
    end

    let(:filterable_fields) do
    end

    let(:hierarchal_fields) do
    end

    let(:matchable_fields) do
    end

    let(:range_fields) do
    end

    let(:properties) do
      {
        downcased_fields: downcased_fields,
        filterable_fields: filterable_fields,
        hierarchal_fields: hierarchal_fields,
        matchable_fields: matchable_fields,
        range_fields: range_fields,
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

      it "returns match query" do
        is_expected.to eq(
          "match" => {
            "_all" => "a",
          },
        )
      end
    end

    context "with double-quoted positive token" do
      let(:query_string) do
        '"a b"'
      end

      it "returns match_phrase query" do
        is_expected.to eq(
          "match_phrase" => {
            "_all" => "a b",
          },
        )
      end
    end

    context "with double-quoted negative token" do
      let(:query_string) do
        '-"a b"'
      end

      it "returns must_not query with match_phrase query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must_not" => [
                  {
                    "match_phrase" => {
                      "_all" => "a b",
                    },
                  },
                ],
              },
            },
          },
        )
      end
    end

    context "with double-quoted token with matchable field names" do
      let(:matchable_fields) do
        ["title"]
      end

      let(:query_string) do
        '"a b"'
      end

      it "returns multi match query with phrase type" do
        is_expected.to eq(
          "multi_match" => {
            "fields" => matchable_fields,
            "query" => "a b",
            "type" => "phrase",
          },
        )
      end
    end

    context "with negative token" do
      let(:query_string) do
        "-a"
      end

      it "returns bool query with must_not property" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must_not" => [
                  "match" => {
                    "_all" => "a",
                  },
                ],
              },
            },
          },
        )
      end
    end

    context "with multiple positive tokens" do
      let(:query_string) do
        "a b"
      end

      it "returns bool query with should property" do
        is_expected.to eq(
          "bool" => {
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

      it "returns bool query with must_not and should properties" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must_not" => [
                  "match" => {
                    "_all" => "b",
                  },
                ],
              },
            },
            "query" => {
              "match" => {
                "_all" => "a",
              },
            },
          },
        )
      end
    end

    context "with fields property" do
      let(:matchable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "a"
      end

      it "returns multi_match query" do
        is_expected.to eq(
          "multi_match" => {
            "fields" => matchable_fields,
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

      it "returns filtered query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "a",
              },
            },
          },
        )
      end
    end

    context "with upcased field name" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "tag:A"
      end

      it "returns filtered query for upcased field name" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "A",
              },
            },
          },
        )
      end
    end

    context "with downcased field name with downcased_fields option" do
      let(:downcased_fields) do
        ["tag"]
      end

      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "tag:A"
      end

      it "returns filtered query for downcased field name" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "a",
              },
            },
          },
        )
      end
    end

    context "with multiple field-named tokens" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "tag:a tag:b"
      end

      it "returns filtered query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must" => [
                  {
                    "term" => {
                      "tag" => "a",
                    },
                  },
                  {
                    "term" => {
                      "tag" => "b",
                    },
                  },
                ],
              },
            },
          },
        )
      end
    end

    context "with escaped colon" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        'tag\:a'
      end

      it "returns match query" do
        is_expected.to eq(
          "match" => {
            "_all" => 'tag\:a',
          },
        )
      end
    end

    context "with token including unknown field name" do
      let(:query_string) do
        "tag:a"
      end

      it "returns match query" do
        is_expected.to eq(
          "match" => {
            "_all" => "tag:a",
          },
        )
      end
    end

    context "with token including field name and minus" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:query_string) do
        "-tag:a"
      end

      it "returns filtered query with bool filter" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "_cache" => true,
                "must_not" => [
                  {
                    "term" => {
                      "tag" => "a",
                    },
                  },
                ],
              },
            },
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

      it "returns bool query with must and should properties" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "term" => {
                "tag" => "b",
              },
            },
            "query" => {
              "match" => {
                "_all" => "a",
              },
            },
          },
        )
      end
    end

    context "with tokens connected with OR token" do
      let(:query_string) do
        "a OR b"
      end

      it "returns bool query with should property" do
        is_expected.to eq(
          "bool" => {
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

      it "returns same query without OR token" do
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

    context "with hierarchal field name" do
      let(:filterable_fields) do
        ["tag"]
      end

      let(:hierarchal_fields) do
        ["tag"]
      end

      let(:query_string) do
        "tag:a"
      end

      it "returns prefix query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "bool" => {
                "should" => [
                  {
                    "prefix" => {
                      "tag" => "a/",
                    },
                  },
                  {
                    "term" => {
                      "tag" => "a",
                    },
                  },
                ],
              },
            },
          },
        )
      end
    end

    context "with range field name" do
      let(:filterable_fields) do
        ["created_at"]
      end

      let(:range_fields) do
        ["created_at"]
      end

      context "and no range operand" do
        let(:query_string) do
          "created_at:2012-02-29"
        end

        it "returns term filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "term" => {
                  "created_at" =>  "2012-02-29"
                },
              },
            },
          )
        end
      end

      context "and < operand" do
        let(:query_string) do
          "created_at:<2012-02-29"
        end

        it "returns range filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "range" => {
                  "created_at" => {
                    "lt" => "2012-02-29"
                  },
                },
              },
            },
          )
        end
      end

      context "and > operand" do
        let(:query_string) do
          "created_at:>2012-02-29"
        end

        it "returns range filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "range" => {
                  "created_at" => {
                    "gt" => "2012-02-29"
                  },
                },
              },
            },
          )
        end
      end

      context "and both < and > operands" do
        let(:query_string) do
          "created_at:>2012-02-29 created_at:<2013-02-28"
        end

        it "returns two range filters within bool filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "bool" => {
                  "_cache" => true,
                  "must" => [
                    {
                      "range" => {
                        "created_at" => {
                          "gt" => "2012-02-29",
                        },
                      },
                    },
                    {
                      "range" => {
                        "created_at" => {
                          "lt" => "2013-02-28",
                        },
                      },
                    },
                  ],
                },
              },
            },
          )
        end
      end
    end
  end
end
