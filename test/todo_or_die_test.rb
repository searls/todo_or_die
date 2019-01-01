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

  def test_config_custom_explosion
    Timecop.travel(Date.civil(2200, 2, 5))
    actual_message, actual_by = nil
    TodoOrDie.config(
      die: ->(message, by) {
        actual_message = message
        actual_by = by
        "pants"
      }
    )
    some_time = Time.parse("2200-02-04")

    result = TodoOrDie("kaka", by: some_time)

    assert_equal result, "pants"
    assert_equal actual_message, "kaka"
    assert_same actual_by, some_time
  end

  def test_config_and_reset
    some_lambda = -> {}
    TodoOrDie.config(die: some_lambda)

    assert_equal TodoOrDie.config[:die], some_lambda
    assert_equal TodoOrDie.config({})[:die], some_lambda

    TodoOrDie.reset

    assert_equal TodoOrDie.config[:die], TodoOrDie::DEFAULT_CONFIG[:die]
  end

  def test_has_version
    assert TodoOrDie::VERSION
  end
end
