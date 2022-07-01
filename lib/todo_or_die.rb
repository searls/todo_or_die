require "time"
require "todo_or_die/version"
require "todo_or_die/overdue_error"

# The namespace
module TodoOrDie
  DEFAULT_CONFIG = {
    die: ->(message, due_at, condition) {
      error_message = [
        "TODO: \"#{message}\"",
        (" came due on #{due_at.strftime("%Y-%m-%d")}" if due_at),
        (" and" if due_at && condition),
        (" has met the conditions to be acted upon" if condition),
        ". Do it!"
      ].compact.join("")

      if defined?(Rails) && Rails.env.production?
        Rails.logger.warn(error_message)
      else
        raise TodoOrDie::OverdueTodo, error_message, TodoOrDie.__clean_backtrace(caller)
      end
    },

    warn: lambda { |message, due_at, warn_at, condition|
      error_message = [
        "TODO: \"#{message}\"",
        (" is due on #{due_at.strftime("%Y-%m-%d")}" if due_at),
        (" and" if warn_at && condition),
        (" has met the conditions to be acted upon" if condition),
        ". Don't forget!"
      ].compact.join("")

      puts error_message

      Rails.logger.warn(error_message) if defined?(Rails)
    }
  }.freeze

  def self.config(options = {})
    @config ||= reset
    @config.merge!(options)
  end

  def self.reset
    @config = DEFAULT_CONFIG.dup
  end

  FILE_PATH_REGEX = Regexp.new(Regexp.quote(__dir__)).freeze
  def self.__clean_backtrace(stack)
    stack.delete_if { |line| line =~ FILE_PATH_REGEX }
  end
end

# The main event
def TodoOrDie(message, by: by_omitted = true, if: if_omitted = true, warn_by: warn_by_omitted = true)
  due_at = Time.parse(by.to_s) unless by_omitted
  warn_at = Time.parse(warn_by.to_s) unless warn_by_omitted
  condition = binding.local_variable_get(:if) unless if_omitted

  is_past_due_date = by_omitted || Time.now > due_at
  die_condition_met = if_omitted || (condition.respond_to?(:call) ? condition.call : condition)
  no_conditions_given = by_omitted && if_omitted && warn_by_omitted
  only_warn_condition_given = (if_omitted && by_omitted && !warn_by_omitted)

  ready_to_die = is_past_due_date && die_condition_met && !only_warn_condition_given
  should_die = no_conditions_given || ready_to_die
  should_warn = !warn_by_omitted && Time.now > warn_at

  if should_die
    die = TodoOrDie.config[:die]
    die.call(*[message, due_at, condition].take(die.arity.abs))
  elsif should_warn
    warn = TodoOrDie.config[:warn]
    warn.call(*[message, due_at, warn_at, condition].take(warn.arity.abs))
  end
end
