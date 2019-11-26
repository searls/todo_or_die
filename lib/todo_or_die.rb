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
        ". Do it!",
      ].compact.join("")

      if defined?(Rails) && Rails.env.production?
        Rails.logger.warn(error_message)
      else
        raise TodoOrDie::OverdueTodo, error_message, TodoOrDie.__clean_backtrace(caller)
      end
    },
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
def TodoOrDie(message, by: by_omitted = true, if: if_omitted = true) # rubocop:disable Naming/MethodName
  due_at = Time.parse(by.to_s) unless by_omitted
  is_due = by_omitted || Time.now > due_at
  condition = binding.local_variable_get(:if) unless if_omitted
  condition_met = if_omitted || (condition.respond_to?(:call) ? condition.call : condition)

  if is_due && condition_met
    die = TodoOrDie.config[:die]
    die.call(*[message, due_at, condition].take(die.arity.abs))
  end
end
