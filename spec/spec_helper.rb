require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  minimum_coverage 100
end

require "codecov"

PROJECT_ROOT ||= File.expand_path("../..", __FILE__)
STUB_PATH ||= File.expand_path(File.join(__FILE__, "..", "stub"))
$:.unshift(STUB_PATH)

Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each { |f| require f }

SimpleCov.formatters = [
  SimpleCov::Formatter::Codecov,
  SimpleCov::Formatter::HTMLFormatter,
]

require "bundle"
require "bundler"

RSpec.configure do |config|
  config.around(:each) do |example|
    Bundler.with_clean_env { example.run }
  end
end

# Stub out the inclusion of Homebrew's code.
LIBS_TO_SKIP = ["formula", "tap", "utils/formatter"].freeze

module Kernel
  alias old_require require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end

HOMEBREW_PREFIX = Pathname.new("/usr/local")
HOMEBREW_REPOSITORY = Pathname.new("/usr/local/Homebrew")

module Formatter
  module_function

  def columns(*)
  end
end

class Formula
  def self.installed
    []
  end
end

class Tap
  def self.map
    []
  end
end
