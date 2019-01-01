require "todo_or_die/version"
require "todo_or_die/overdue_error"

# The namespace
module TodoOrDie
  DEFAULT_CONFIG = {
    die: ->(message, due_at) {
      error_message = <<~MSG
        TODO: "#{message}" came due on #{due_at.strftime("%Y-%m-%d")}. Do it!
      MSG

      if defined?(Rails) && Rails.env.production?
        Rails.logger.warn(error_message)
      else
        raise TodoOrDie::OverdueTodo.new(error_message)
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
end

# The main event
def TodoOrDie(message, by:) # rubocop:disable Naming/MethodName
  due_at = by.to_time

  if Time.now >= due_at
    TodoOrDie.config[:die].call(message, due_at)
  end
end
