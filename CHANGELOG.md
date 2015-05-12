## 0.10.0
- Add sort:updated-asc and sort:updated-desc tokens

## 0.9.1
- Add positive option to Query#has_field_token?

## 0.9.0
- Add is:archived filter token for projects

## 0.8.0
- Add is:project & is:article tokens

## 0.7.1
- Take empty token query as any matcher

## 0.7.0
- Support `is:coediting` query
- Change default sort order with created-desc
- Improve some filter options and Query methods

## 0.6.0
- Change `Query#to_hash` behavior and support sort option

## 0.5.0
- Change `QueryBuilder#build` to return `Query` object

## 0.4.0
- Change range fields to use integer
- Support date fields
- Support time_zone parameter
- Rename range_fields parameter as int_fields
- Return a null query if an invalid query string is given

## 0.3.0
- Add downcased_fields options and update case rule

## 0.2.2
- Support range fields

## 0.2.1
- Fix _cache property on filtered queries

## 0.2.0
- Use filtered query for negative or filter tokens

## 0.1.4
- Use downcased term for term and prefix on filtered query

## 0.1.3
- Fix bug on negative token with field name

## 0.1.2
- Fix filter query for hierarchal fields

## 0.1.1
- Support hierarchal fields

## 0.1.0
- 1st Release
