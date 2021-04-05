# frozen_string_literal: true

ruby '2.7.2'
source 'https://rubygems.org'

gemspec

# Runtime dependency
gem 'rack', '~> 2.0'

# Pin Sinatra version temporarily,
# because Sinatra 2.0.5 has below issue that prevents our unit tests to pass.
# It will be fixed on the next release.
# https://github.com/sinatra/sinatra/commit/d8c1839
gem 'sinatra', '2.0.4'

group 'test' do
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'guard-rubocop', '~> 1.4'
end
