require "date"

require "todo_or_die/version"
require "todo_or_die/overdue_error"

# The namespace
module TodoOrDie
end

# The main event
def TodoOrDie(message, by:) # rubocop:disable Naming/MethodName
  due_at = by.to_time

  if Time.now >= due_at
    raise TodoOrDie::OverdueTodo.new <<~MSG
      TODO: "#{message}" came due on #{due_at.strftime("%Y-%m-%d")}. Do it!
    MSG
  end
end
