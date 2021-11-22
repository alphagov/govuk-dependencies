require "active_support"
require "dalli"

module CacheStore
  CACHE_EXPIRY = 43_200 # 12 hours

  def self.memcached
    @memcached ||=
      Dalli::Client.new(
        ENV["MEMCACHIER_SERVERS"], {
          username: ENV["MEMCACHIER_USERNAME"],
          password: ENV["MEMCACHIER_PASSWORD"],
          expires_in: CACHE_EXPIRY,
        }
      )
  end

  def self.filestore
    @filestore ||= ActiveSupport::Cache::FileStore.new(".cache")
  end

  def self.store
    cache_store = ENV["RACK_ENV"] == "production" ? memcached : filestore
    Store.new(cache_store)
  end
end

class CacheStore::Store < SimpleDelegator
  def initialize(cache)
    super
    @cache = cache
  end

  def clear
    @cache.respond_to?(:flush_all) ? @cache.flush_all : @cache.clear
  end

  def write(key, value)
    @cache.respond_to?(:set) ? @cache.set(key, value) : @cache.write(key, value)
  end
end
