# Qiita::Elasticsearch [![Build Status](https://travis-ci.org/increments/qiita-elasticsearch.svg)](https://travis-ci.org/increments/qiita-elasticsearch) [![Code Climate](https://codeclimate.com/github/increments/qiita-elasticsearch/badges/gpa.svg)](https://codeclimate.com/github/increments/qiita-elasticsearch)
Elasticsearch client helper for Qiita.

## Usage
```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new
#=> #<Qiita::Elasticsearch::QueryBuilder:0x007ff81e67c4d8 @filterable_fields=nil, @matchable_fields=nil>

query_builder.build("a")
#=> {"match"=>{"_all"=>"a"}}

query_builder.build("a b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"a"}}, {"match"=>{"_all"=>"b"}}]}}

query_builder.build("a -b")
#=> {"bool"=>{"must_not"=>[{"match"=>{"_all"=>"b"}}], "should"=>[{"match"=>{"_all"=>"a"}}]}}

query_builder.build('"a b"')
#=> {"match_phrase"=>{"_all"=>"a b"}}

query_builder.build("a OR b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"a"}}, {"match"=>{"_all"=>"b"}}]}}

```

### matchable_fields
```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(matchable_fields: ["body", "title"])
#=> #<Qiita::Elasticsearch::QueryBuilder:0x007ff81fa59168 @filterable_fields=nil, @matchable_fields=["body", "title"]>

query_builder.build("a")
#=> {"multi_match"=>{"fields"=>["body", "title"], "query"=>"a"}}
```

### filterable_fields
```rb
query_builder = Qiita::Elasticsearch::QueryBuilder.new(filterable_fields: ["tag", "title"])
#=> #<Qiita::Elasticsearch::QueryBuilder:0x007ff81e2de1f0 @filterable_fields=["tag", "title"], @matchable_fields=nil>

query_builder.build("tag:a")
#=> {"filtered"=>{"filter"=>{"term"=>{"tag"=>"a"}}, "query"=>{"match_all"=>{}}}}

query_builder.build("tag:a b")
#=> {"bool"=>{"must"=>[{"filtered"=>{"filter"=>{"term"=>{"tag"=>"a"}}, "query"=>{"match_all"=>{}}}}], "should"=>[{"match"=>{"_all"=>"b"}}]}}

query_builder.build("user:a b")
#=> {"bool"=>{"should"=>[{"match"=>{"_all"=>"user:a"}}, {"match"=>{"_all"=>"b"}}]}}
```
