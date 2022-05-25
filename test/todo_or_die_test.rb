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

    assert_equal <<~MSG.chomp, error.message
      TODO: "Fix stuff" came due on 2200-02-04. Do it!
    MSG
  end

  def test_warn_todo_warns
    Timecop.travel(Date.civil(2200, 2, 4))

    out, _err = capture_io {
      TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 5), warn_by: Date.civil(2200, 2, 4))
    }

    assert_equal <<~MSG.chomp, out.strip
      TODO: "Fix stuff" is due on 2200-02-05. Don't forget!
    MSG
  end

  def test_doesnt_warn_early
    Timecop.travel(Date.civil(2200, 2, 3))

    out, _err = capture_io {
      TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 5), warn_by: Date.civil(2200, 2, 4))
    }

    assert_equal "", out.strip
  end

  def test_config_warn
    Timecop.travel(Date.civil(2200, 2, 5))
    actual_message, actual_by = nil
    TodoOrDie.config(
      warn: ->(message, by) {
        actual_message = message
        actual_by = by
        "pants"
      }
    )
    some_time = Time.parse("2200-02-06")
    some_earlier_time = Time.parse("2200-02-03")

    result = TodoOrDie("kaka", by: some_time, warn_by: some_earlier_time)

    assert_equal result, "pants"
    assert_equal actual_message, "kaka"
    assert_equal actual_by, some_time
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
    assert_equal actual_by, some_time
  end

  def test_config_custom_0_arg_die_callable
    Timecop.travel(Date.civil(2200, 2, 5))
    TodoOrDie.config(
      die: -> {
        :neat
      }
    )

    result = TodoOrDie(nil, by: "2200-02-04")

    assert_equal result, :neat
  end

  def test_config_custom_1_arg_die_callable
    Timecop.travel(Date.civil(2200, 2, 5))
    actual_message = nil
    TodoOrDie.config(
      die: ->(message) {
        actual_message = message
        :cool
      }
    )
    some_time = Time.parse("2200-02-04")

    result = TodoOrDie("secret", by: some_time)

    assert_equal result, :cool
    assert_equal actual_message, "secret"
  end

  def test_config_and_reset
    some_lambda = -> {}
    TodoOrDie.config(die: some_lambda)

    assert_equal TodoOrDie.config[:die], some_lambda
    assert_equal TodoOrDie.config({})[:die], some_lambda

    TodoOrDie.reset

    assert_equal TodoOrDie.config[:die], TodoOrDie::DEFAULT_CONFIG[:die]
  end

  def test_when_rails_is_a_thing_and_not_production
    make_it_be_rails(false)

    Timecop.travel(Date.civil(1980, 1, 20))

    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("I am in Rails", by: Date.civil(1980, 1, 15))
    }
  end

  def test_when_rails_is_a_thing_and_is_production
    faux_logger = make_it_be_rails(true)

    Timecop.travel(Date.civil(1980, 1, 20))

    TodoOrDie("Solve the Iranian hostage crisis", by: Date.civil(1980, 1, 20))

    assert_equal <<~MSG.chomp, faux_logger.warning
      TODO: "Solve the Iranian hostage crisis" came due on 1980-01-20. Do it!
    MSG
  end

  def test_warn_when_rails_is_a_thing
    faux_logger = make_it_be_rails(true)

    Timecop.travel(Date.civil(2200, 2, 4))

    TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 5), warn_by: Date.civil(2200, 2, 4))

    assert_equal <<~MSG.chomp, faux_logger.warning
      TODO: "Fix stuff" is due on 2200-02-05. Don't forget!
    MSG
  end

  def test_todo_or_die_file_path_removed_from_backtrace
    Timecop.travel(Date.civil(2200, 2, 4))

    error = assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Fix stuff", by: Date.civil(2200, 2, 4))
    }

    assert_empty(error.backtrace.select { |line| line.match?(/todo_or_die\.rb/) })
  end

  def test_has_version
    assert TodoOrDie::VERSION
  end

  def test_by_string_due_blows_up
    Timecop.travel(Date.civil(2200, 2, 4))

    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Feelin' stringy", by: "2200-02-04")
    }
  end

  def test_by_string_not_due_does_not_blow_up
    Timecop.travel(Date.civil(2100, 2, 4))

    TodoOrDie("Feelin' stringy", by: "2200-02-04")

    # 🦗 sounds
  end

  def test_due_when_no_by_or_if_is_passed
    Timecop.travel(Date.civil(2200, 2, 4))

    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Check your math")
    }
  end

  def test_due_and_if_condition_is_true_blows_up
    Timecop.travel(Date.civil(2200, 2, 4))

    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Check your math", by: Date.civil(2200, 2, 4), if: -> { 2 + 2 == 4 })
    }
  end

  def test_not_due_and_if_condition_is_true_does_not_blow_up
    Timecop.travel(Date.civil(2100, 2, 4))

    TodoOrDie("Check your math", by: Date.civil(2200, 2, 4), if: -> { 2 + 2 == 4 })

    # 🦗 sounds
  end

  def test_due_and_if_condition_is_false_does_not_blow_up
    Timecop.travel(Date.civil(2200, 2, 4))

    TodoOrDie("Check your math", by: Date.civil(2200, 2, 4), if: -> { 2 + 2 == 5 })

    # 🦗 sounds
  end

  def test_by_not_passed_and_if_condition_is_true_blows_up
    error = assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Check your math", if: -> { 2 + 2 == 4 })
    }

    assert_equal <<~MSG.chomp, error.message
      TODO: "Check your math" has met the conditions to be acted upon. Do it!
    MSG
  end

  def test_by_and_if_condition_both_true_prints_full_message
    error = assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Stuff", by: "1904-02-03", if: -> { true })
    }

    assert_equal <<~MSG.chomp, error.message
      TODO: "Stuff" came due on 1904-02-03 and has met the conditions to be acted upon. Do it!
    MSG
  end

  def test_no_condition_passed_prints_short_message
    error = assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Stuff")
    }

    assert_equal <<~MSG.chomp, error.message
      TODO: "Stuff". Do it!
    MSG
  end

  def test_by_not_passed_and_if_condition_false_does_not_blow_up
    TodoOrDie("Check your math", if: -> { 2 + 2 == 5 })

    # 🦗 sounds
  end

  def test_by_not_passed_and_if_condition_is_false_boolean_does_not_blow_up
    TodoOrDie("Check your math", if: false)

    # 🦗 sounds
  end

  def test_by_not_passed_and_if_condition_is_true_boolean_blows_up
    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Check your math", if: true)
    }
  end

  def test_by_not_passed_and_if_condition_is_truthy_blows_up
    assert_raises(TodoOrDie::OverdueTodo) {
      TodoOrDie("Check your math", if: 42)
    }
  end

  def test_by_not_passed_and_if_condition_is_falsy_does_not_blow_up
    TodoOrDie("Check your math", if: nil)

    # 🦗 sounds
  end
end
