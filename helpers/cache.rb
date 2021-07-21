def cache(name, cache_duration_seconds = 120, &block)
  return yield unless ENV["RACK_ENV"] == "production"

  UseCases::Cache.new(
    path: "#{Dir.pwd}/public/cache/#{name}.html",
  ).execute(cache_duration_seconds: cache_duration_seconds, &block)
end
