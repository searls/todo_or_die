require 'time'
require 'todo_or_die/version'
require 'todo_or_die/overdue_error'

# The namespace
module TodoOrDie
  DEFAULT_CONFIG = {
    warn: lambda { |message, due_at, condition|
            error_message = [
              "TODO: \"#{message}\"",
              (" will nearly come due on #{due_at.strftime('%Y-%m-%d')}" if due_at),
              (' and' if due_at && condition),
              (' has met the conditions to be acted upon' if condition),
              '. Think of it, soon!'
            ].compact.join('')

            if defined?(Rails) && Rails.env.production?
              Rails.logger.warn(error_message)
            else
              puts error_message
            end
          },
    die: lambda { |message, due_at, condition|
           error_message = [
             "TODO: \"#{message}\"",
             (" came due on #{due_at.strftime('%Y-%m-%d')}" if due_at),
             (' and' if due_at && condition),
             (' has met the conditions to be acted upon' if condition),
             '. Do it!'
           ].compact.join('')

           if defined?(Rails) && Rails.env.production?
             Rails.logger.warn(error_message)
           else
             raise TodoOrDie::OverdueTodo, error_message, TodoOrDie.__clean_backtrace(caller)
           end
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
def TodoOrDie(message, options = {})
  options[:by] ||= by_omitted = true
  options[:if] ||= if_omitted = true
  options[:warn_by] ||= warn_by_omitted = true
  options[:warn_if] ||= warn_if_omitted = true

  warn_at = Time.parse(by.to_s) unless warn_by_omitted
  is_warn = warn_by_omitted || Time.now > warn_at
  condition = options[:warn_if] unless warn_if_omitted
  warn_condition_met = warn_if_omitted || (condition.respond_to?(:call) ? condition.call : condition)

  if is_warn && warn_condition_met
    warn = TodoOrDie.config[:warn]
    warn.call(*[message, warn_at, condition].take(warn.arity.abs))
  end

  due_at = Time.parse(by.to_s) unless by_omitted
  is_due = by_omitted || Time.now > due_at
  condition = options[:if] unless if_omitted
  condition_met = if_omitted || (condition.respond_to?(:call) ? condition.call : condition)

  if is_due && condition_met
    die = TodoOrDie.config[:die]
    die.call(*[message, due_at, condition].take(die.arity.abs))
  end
end
