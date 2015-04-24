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

    let(:int_fields) do
    end

    let(:date_fields) do
    end

    let(:time_zone) do
    end

    let(:properties) do
      {
        downcased_fields: downcased_fields,
        filterable_fields: filterable_fields,
        hierarchal_fields: hierarchal_fields,
        matchable_fields: matchable_fields,
        int_fields: int_fields,
        date_fields: date_fields,
        time_zone: time_zone,
      }
    end

    let(:query_builder) do
      described_class.new(properties)
    end

    context "with empty string" do
      let(:query_string) do
        ""
      end

      it "returns null" do
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

    context "with invalid int token" do
      let(:filterable_fields) do
        ["stocks"]
      end

      let(:int_fields) do
        ["stocks"]
      end

      let(:query_string) do
        "stocks:invalid"
      end

      it "returns null filtered query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "query" => {
                "ids" => {
                  "values" => [],
                },
              },
            },
          },
        )
      end
    end

    context "with negative invalid int token" do
      let(:filterable_fields) do
        ["stocks"]
      end

      let(:int_fields) do
        ["stocks"]
      end

      let(:query_string) do
        "-stocks:invalid"
      end

      it "ignores negative invalid int " do
        is_expected.to eq(
          "query" => {
            "ids" => {
              "values" => [],
            },
          },
        )
      end
    end

    context "with range field name" do
      let(:filterable_fields) do
        ["stocks"]
      end

      let(:int_fields) do
        ["stocks"]
      end

      context "and no range operand" do
        let(:query_string) do
          "stocks:100"
        end

        it "returns term filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "term" => {
                  "stocks" => 100,
                },
              },
            },
          )
        end
      end

      context "and < operand" do
        let(:query_string) do
          "stocks:<100"
        end

        it "returns range filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "range" => {
                  "stocks" => {
                    "lt" => 100,
                  },
                },
              },
            },
          )
        end
      end

      context "and > operand" do
        let(:query_string) do
          "stocks:>100"
        end

        it "returns range filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "range" => {
                  "stocks" => {
                    "gt" => 100,
                  },
                },
              },
            },
          )
        end
      end

      context "and multiple operands" do
        let(:query_string) do
          "stocks:>=100 stocks:<=200"
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
                        "stocks" => {
                          "gte" => 100,
                        },
                      },
                    },
                    {
                      "range" => {
                        "stocks" => {
                          "lte" => 200,
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

    context "with invalid date token" do
      let(:date_fields) do
        ["created_at"]
      end

      let(:filterable_fields) do
        ["created_at"]
      end

      let(:query_string) do
        "created_at:invalid"
      end

      it "returns null filtered query" do
        is_expected.to eq(
          "filtered" => {
            "filter" => {
              "query" => {
                "ids" => {
                  "values" => [],
                },
              },
            },
          },
        )
      end
    end

    context "with invalid date token and OR token" do
      let(:date_fields) do
        ["created_at"]
      end

      let(:filterable_fields) do
        ["created_at"]
      end

      let(:query_string) do
        "created_at:invalid OR Ruby"
      end

      it "returns query that matches Ruby" do
        is_expected.to eq(
          "bool" => {
            "should" => [
              {
                "filtered" => {
                  "filter" => {
                    "query" => {
                      "ids" => {
                        "values" => [],
                      },
                    },
                  },
                },
              },
              {
                "match" => {
                  "_all" => "Ruby",
                },
              },
            ],
          },
        )
      end
    end

    context "with date field name" do
      let(:filterable_fields) do
        ["created_at"]
      end

      let(:date_fields) do
        ["created_at"]
      end

      context "and no range operand" do
        context "and query is YYYY" do
          let(:query_string) do
            "created_at:2015"
          end

          it "returns range filter" do
            is_expected.to eq(
              "filtered" => {
                "filter" => {
                  "range" => {
                    "created_at" => {
                      "gte" => "2015-01-01",
                      "lt" => "2016-01-01"
                    }
                  },
                },
              },
            )
          end
        end

        context "and query is YYYY-MM" do
          let(:query_string) do
            "created_at:2015-04"
          end

          it "returns range filter" do
            is_expected.to eq(
              "filtered" => {
                "filter" => {
                  "range" => {
                    "created_at" => {
                      "gte" => "2015-04-01",
                      "lt" => "2015-05-01"
                    }
                  },
                },
              },
            )
          end
        end

        context "and query is YYYY-MM-DD" do
          let(:query_string) do
            "created_at:2015-04-17"
          end

          it "returns range filter" do
            is_expected.to eq(
              "filtered" => {
                "filter" => {
                  "range" => {
                    "created_at" => {
                      "gte" => "2015-04-17",
                      "lt" => "2015-04-18"
                    }
                  },
                },
              },
            )
          end
        end

        context "and time_zone" do
          let(:time_zone) do
            "+09:00"
          end

          let(:query_string) do
            "created_at:2015-04-17"
          end

          it "returns range filter with time_zone" do
            is_expected.to eq(
              "filtered" => {
                "filter" => {
                  "range" => {
                    "created_at" => {
                      "gte" => "2015-04-17",
                      "lt" => "2015-04-18",
                      "time_zone" => time_zone,
                    }
                  },
                },
              },
            )
          end
        end
      end

      context "and single operand" do
        let(:query_string) do
          "created_at:<2015-04"
        end

        it "returns range filter" do
          is_expected.to eq(
            "filtered" => {
              "filter" => {
                "range" => {
                  "created_at" => {
                    "lt" => "2015-04",
                  },
                },
              },
            },
          )
        end

        context "and time_zone" do
          let(:time_zone) do
            "+09:00"
          end

          it "returns range filter with time_zone" do
            is_expected.to eq(
              "filtered" => {
                "filter" => {
                  "range" => {
                    "created_at" => {
                      "lt" => "2015-04",
                      "time_zone" => time_zone,
                    },
                  },
                },
              },
            )
          end
        end
      end

      context "and multiple operands" do
        let(:query_string) do
          "created_at:>=2015-04-01 created_at:<=2015-04-17"
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
                          "gte" => "2015-04-01",
                        },
                      },
                    },
                    {
                      "range" => {
                        "created_at" => {
                          "lte" => "2015-04-17",
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
