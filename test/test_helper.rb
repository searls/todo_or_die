require "minitest/autorun"
require "timecop"

require "todo_or_die"

class UnitTest < Minitest::Test
  def teardown
    Timecop.return
    TodoOrDie.reset
  end
end
