require "qiita/elasticsearch/query_builder"

RSpec.describe Qiita::Elasticsearch::QueryBuilder do
  describe ".new" do
    it { is_expected.to be_a described_class }
  end
end
