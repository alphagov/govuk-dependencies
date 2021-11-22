RSpec.describe CacheStore do
  let(:store) { double("store") }
  let(:cache_store) { CacheStore::Store.new(store) }

  it "Store delegates to the passed object" do
    expect(store).to receive(:foo)
    cache_store.foo
  end

  # dalli/memcached
  context "when the store defines a 'flush_all' method" do
    it ".clear delegates 'flush_all' to the passed object" do
      allow(store).to receive(:flush_all) { true }
      expect(store).not_to receive(:clear)
      expect(store).to receive(:flush_all)

      cache_store.clear
    end
  end

  context "when the store defines a 'set' method" do
    it ".write delegates 'set' to the passed object" do
      allow(store).to receive(:set) { true }
      expect(store).not_to receive(:write)
      expect(store).to receive(:set)

      cache_store.write("foo", "bar")
    end
  end

  # active_support/filestore
  context "when the store has no 'flush_all' method" do
    it ".clear delegates 'clear' to the passed object" do
      expect(store).to receive(:clear)
      cache_store.clear
    end
  end

  context "when the store has no 'set' method" do
    it ".write delegates 'write' to the passed object" do
      expect(store).to receive(:write)
      cache_store.write("foo", "bar")
    end
  end
end
