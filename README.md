# Qiita::Elasticsearch [![Build Status](https://travis-ci.org/increments/qiita-elasticsearch.svg)](https://travis-ci.org/increments/qiita-elasticsearch) [![Code Climate](https://codeclimate.com/github/increments/qiita-elasticsearch/badges/gpa.svg)](https://codeclimate.com/github/increments/qiita-elasticsearch) [![Test Coverage](https://codeclimate.com/github/increments/qiita-elasticsearch/badges/coverage.svg)](https://codeclimate.com/github/increments/qiita-elasticsearch)
Elasticsearch client helper for Qiita.

## Usage
`Qiita::Elasticsearch::QueryBuilder` builds Elasticsearch query from query string.

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new

query_builder.build("a")
#=> {"match"=>{"_all"=>"a"}}

query_builder.build("a b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"a"}}, {"match"=>{"_all"=>"b"}}]}}

query_builder.build("a -b")
#=> {"filtered"=> {"filter"=>{"bool"=>{"_cache"=>true, "must_not"=>[{"match"=>{"_all"=>"b"}}]}}, "query"=>{"match"=>{"_all"=>"a"}}}}

query_builder.build('"a b"')
#=> {"match_phrase"=>{"_all"=>"a b"}}

query_builder.build("a OR b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"a"}}, {"match"=>{"_all"=>"b"}}]}}
```

### matchable_fields
Pass `:matchable_fields` option to tell matchable field names (default: `_all`).

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(matchable_fields: ["body", "title"])

query_builder.build("a")
#=> {"multi_match"=>{"fields"=>["body", "title"], "query"=>"a"}}
```

### filterable_fields
Pass `:filterable_fields` option to enable filtered queries like `tag:Ruby`.

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(filterable_fields: ["tag", "title"])

query_builder.build("tag:a")
#=> {"filtered"=>{"filter"=>{"term"=>{"tag"=>"a"}}}}

query_builder.build("tag:a b")
#=> {"filtered"=>{"filter"=>{"term"=>{"tag"=>"a"}}, "query"=>{"match"=>{"_all"=>"b"}}}}

query_builder.build("user:a b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"user:a"}}, {"match"=>{"_all"=>"b"}}]}}
```

### hierarchal_fields
Pass `:hierarchal_fields` option with `:filterable_fields` to enable prefixed filtered queries.
With this option, `tag:foo` will hit documents tagged with `foo`, or `foo/...`.

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(filterable_fields: ["tag"], hierarchal_fields: ["tag"])

query_builder.build("tag:ruby")
#=> {"filtered"=>{"filter"=>{"bool"=>{"should"=>[{"prefix"=>{"tag"=>"ruby/"}}, {"term"=>{"tag"=>"ruby"}}]}}}}
```

### range_fields
Pass `:range_fields` option with `:filterable_fields` to enable range filtered queries.
With this option, `created_at:<2015-04-16` will hit documents created before 2015-04-16.

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(filterable_fields: ["created_at"], range_fields: ["created_at"])

query_builder.build("created_at:<2015-04-16")
#=> {"filtered"=>{"filter"=>{"range"=>{"created_at"=>{"lt"=>"2015-04-16"}}}}}
```

### downcased_fields
Pass `:downcased_fields` option with `:filterable_fields` to downcase any terms in the fields.
This option is useful when some fields are stored within downcased format on Elasticsearch.

```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(downcased_fields: ["tag"], filterable_fields: ["tag"])

query_builder.build("tag:Ruby")
#=> {"filtered"=>{"filter"=>{"term"=>{"tag"=>"ruby"}}}}
```
