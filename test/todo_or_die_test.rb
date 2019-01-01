require "test_helper"

class TodoOrDieTest < UnitTest
  def test_not_due_todo_does_nothing
    Timecop.travel(Date.civil(2200, 2, 3))

    TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 4))

    # 🦗 sounds
  end

  def test_due_todo_blows_up
    Timecop.travel(Date.civil(2200, 2, 4))

    error = assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 4))
    }

    assert_equal <<~MSG, error.message
      TODO: "Fix stuff" came due on 2200-02-04. Do it!
    MSG
  end
end
