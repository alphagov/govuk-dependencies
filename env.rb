require "bundler/setup"

APP_ENV = ENV["RACK_ENV"] || "development"

Bundler.require :default, APP_ENV.to_sym
