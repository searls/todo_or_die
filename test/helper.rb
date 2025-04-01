require "ostruct"
require "timecop"
Timecop.thread_safe = true

require "todo_or_die"

require "tldr"
if defined?(Minitest::Test)
  TLDR::MinitestTestBackup = Minitest::Test
  Minitest.send(:remove_const, "Test")
end
module Minitest
  class Test < TLDR
    include TLDR::MinitestCompatibility
  end
end

class UnitTest < Minitest::Test
  def teardown
    Timecop.return
    TodoOrDie.reset
    Object.send(:remove_const, :Rails) if defined?(Rails)
  end

  def make_it_be_rails(is_production)
    rails = Object.const_set(:Rails, Module.new)

    rails.define_singleton_method(:env) do
      OpenStruct.new(production?: is_production)
    end

    fake_logger = FauxLogger.new
    rails.define_singleton_method(:logger) do
      fake_logger
    end

    fake_logger
  end

  class FauxLogger
    attr_reader :warning

    def warn(message)
      @warning = message
    end
  end
end
