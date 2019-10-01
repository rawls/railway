# frozen_string_literal: true

ENV['ENVIRONMENT'] = 'test'

# Testing libraries
require 'webmock/rspec'
require 'timecop'

# Must be required before the code
require 'simplecov'
require_relative 'support/svg_badge_formatter'
formatters = [SimpleCov::Formatter::HTMLFormatter, SvgBadgeFormatter]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
SimpleCov.start do
  minimum_coverage 90
  minimum_coverage_by_file 80
  add_filter '/spec/'
  add_group 'Railway',   'lib/railway'
  add_group 'OpenLDBWS', 'lib/railway/ldbws'
  add_group 'CLI',       'lib/railway/cli'
end

# Test helpers
require_relative 'support/open_ldbws_dummy'
require_relative 'support/helpers'

# The code
require_relative '../lib/railway'

# Disable all outgoing HTTP during testing
WebMock.disable_net_connect!(allow_localhost: true)

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.before do
    # Send cricinfo requests to my dummy CricInfo
    stub_request(:any, /nationalrail.co.uk/).to_rack(OpenLdbwsDummy)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true
  config.profile_examples = 3
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
