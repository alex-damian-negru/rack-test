# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'rspec'
require 'rspec/its'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

require 'rack/test'
require "#{File.dirname(__FILE__)}/fixtures/fake_app"

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods

  config.filter_run_when_matching :focus

  def app
    Rack::Lint.new(Rack::Test::FakeApp.new)
  end
end
