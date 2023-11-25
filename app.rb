# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "7.1.2"
  # gem "sqlite3"
  gem "pg"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  encoding: "unicode",
  database: ENV["DB_NAME"],
  username: "postgres",
  password: "",
  host: ENV["DB_HOST"],
)


ActiveRecord::Base.logger = Logger.new(STDOUT)

module IdVerifiable
  extend ActiveSupport::Concern

  included do
    enum id_verification_status: { unverified: 0, verified: 1 }
  end
end

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.integer :id_verification_status, default: 0
  end
end


class User < ActiveRecord::Base
  enum id_verification_status: { unverified: 0, verified: 1 }
end

class BugTest < Minitest::Test
  def test_create_unverified_user
    user = User.create!

    assert_equal "unverified", user.id_verification_status
  end
  def test_create_verified_user
    user = User.create!(id_verification_status: :verified)

    assert_equal "verified", user.id_verification_status
  end
end