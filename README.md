# TODO or Die!

<img src="https://user-images.githubusercontent.com/79303/50570550-f41a6180-0d5d-11e9-8033-7ea4dfb7261c.jpg" height="360"  alt="TODO or Die NES cart"/>

## Usage

Stick this in your Gemfile and bundle it:

```ruby
gem "todo_or_die"
```

Once required, you can mark TODOs for yourself anywhere you like:

```ruby
TodoOrDie("Update after APIv2 goes live", by: Date.civil(2019, 2, 4))
```

To understand why you would ever call a method to write a comment, read on.

### The awful way you used to procrastinate

In the Bad Old Days™, if you had a bit of code you knew needed to change later,
you might leave yourself a code comment to remind yourself or some future
traveler to implement it.

Here's the real world example code comment that inspired this gem:

``` ruby
class UsersController < ApiController
  # TODO: remember to delete after JS app has propagated
  def show
    redirect_to root_path
  end
end
```

This was bad. The comment did nothing to remind myself or anyone else to
actually delete the code. Because no one was working on this part of the system
for a while, the _continued existence of the redirect_ eventually resulted in an
actual support incident (long story).

### The cool new way you put off coding now

So I did what any programmer would do in the face of an intractable social
problem: I wrote code in the vain hope of solving it without having to talk to
anyone.

To use the gem, try replacing one of your TODO comments with something like
this:

``` ruby
class UsersController < ApiController
  TodoOrDie("delete after JS app has propagated", by: Time.parse("2019-02-04"))
  def show
    redirect_to root_path
  end
end
```

Nothing will happen at all until February 4th, at which point the gem will
raise an error whenever this class is loaded until someone deals with it.

### What kind of error?

It depends on whether `Rails` is defined.

#### When you're writing Real Ruby

If you're not using Rails (i.e. `defined?(Rails)` is false), then the gem will
raise a `TodoOrDie::OverdueError` whenever a TODO is overdue. The message looks
like this:

```
TODO: "Visit Wisconsin" came due on 2016-11-9. Do it!
```

#### When `Rails` is a thing

If TodoOrDie sees that `Rails` is defined, it'll assume you probably don't want
this tool to run outside development and test, so it'll log the error message to
`Rails.logger.warn` in production and raise the error otherwise.

### Wait, won't raising time-based errors throughout my app ruin my weekend?

Sure will! It's TODO or Die, not TODO and Remember to Pace Yourself.

Still, people will probably get mad if you break production because you forgot
to remove an A/B test, so I'd [strongly recommend you read what the default hook
actually does](lib/todo_or_die.rb) before you commit any to-do items to your
codebase.

You can customize the gem's behavior by passing in your own callable
lambda/proc/thing like this:

```ruby
TodoOrDie.config(
  die: ->(message, due_at) {
    if message.include?("Karen")
      raise "Hey Karen your code's broke"
    end
  }
)
```

Now, any `TodoOrDie()` invocations in your codebase (other than Karen's) will be
ignored. (You can reset this with `TodoOrDie.reset`).

## When is this useful?

Any time you know the code needs to change, but it can't change right now, and
you lack some other reliable means of ensuring yourself (or your team)
will actually follow through on making the change later.

However, recall that [LeBlanc's
Law](https://www.quora.com/What-resources-could-I-read-about-Leblancs-law)
states that `Later == Never`, countless proofs of which have been demonstrated
by software teams around the world. Some common examples:

* A feature flag was added to the app, and the old code path is still present,
  long after all production traffic has been migrated with a useless `TODO:
  delete` comment to keep it company
* A failing test is blocking the build and there's an urgent pressure to deploy,
  and insufficient time to fix the test, so somebody wants to comment the test
  out "for now"
* You're a real funny person and you think it'd be hilarious to make a bunch of
  Jim's tests start failing on Christmas morning

## Pro-tip

Cute Rails date helpers are awesome, but don't think you're going to be able to
do this and actually accomplish anything:

```ruby
TodoOrDie("Update after APIv2 goes live", 2.weeks.from_now)
```


