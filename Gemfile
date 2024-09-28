source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1"

gem "pg", "~> 1.5"

gem "aasm", "~> 5.5"
gem "after_commit_everywhere", "~> 1.0"

gem "sidekiq", "~> 7.3"

gem "puma", ">= 5.0"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

group :development, :test do
  gem "pry-rails"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "assert_json"
end
