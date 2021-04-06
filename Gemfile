# frozen_string_literal: true

ruby '3.0.0'
source 'https://rubygems.org'

gemspec

# Runtime dependency
gem 'rack', '~> 2.0'
gem 'sinatra', git: 'https://github.com/andrewtblake/sinatra.git', branch: 'master'

group :development, :test do
  gem 'guard-reek', '~> 1.2'
  gem 'guard-rubocop', '~> 1.4'
  gem 'pry-byebug', '~> 3.9', platform: :mri
  gem 'reek', '~> 6.0'
  gem 'rubocop', '~> 1.12.1'
  gem 'rubocop-performance', '~> 1.10.2'
  gem 'rubocop-rake', '~> 0.5.1'
  gem 'rubocop-rspec', '~> 2.2'
end

group :test do
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'rspec', '~> 3.10'
  gem 'rspec-its', '~> 1.3'
end
