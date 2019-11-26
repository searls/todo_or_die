require "todo_or_die/version"
require "todo_or_die/overdue_error"

# The namespace
module TodoOrDie
  DEFAULT_CONFIG = {
    die: ->(message, due_at = nil) {
      error_message = if due_at
        <<~MSG
          TODO: "#{message}" came due on #{due_at.strftime("%Y-%m-%d")}. Do it!
        MSG
      else
        <<~MSG
          TODO: "#{message}" has met the conditions to be acted upon. Do it!
        MSG
      end

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
def TodoOrDie(message, by: nil, if: -> { true }) # rubocop:disable Naming/MethodName
  if by
    by_passed = true
  end

  condition = binding.local_variable_get(:if)
  if condition.respond_to?(:call) && condition.call || condition == true
    due_at = by_passed ? Time.parse(by.to_s) : Time.now

    if Time.now >= due_at
      if by_passed
        TodoOrDie.config[:die].call(message, due_at)
      else
        TodoOrDie.config[:die].call(message)
      end
    end
  end
end
