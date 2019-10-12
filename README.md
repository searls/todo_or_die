# TODO or Die!

<img src="https://user-images.githubusercontent.com/79303/50570550-f41a6180-0d5d-11e9-8033-7ea4dfb7261c.jpg" height="360"  alt="TODO or Die NES cart"/>

[![CircleCI](https://circleci.com/gh/searls/todo_or_die/tree/master.svg?style=svg)](https://circleci.com/gh/searls/todo_or_die/tree/master)

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

In the Bad Old Days™, if you had a bit of code you knew you needed to change
later, you might leave yourself a code comment to remind yourself to change it.
For example, here's the real world code comment that inspired this gem:

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
problem: I wrote code in the vain hope of solving things without needing to talk
to anyone. And now this gem exists.

To use it, try replacing one of your TODO comments with something like this:

``` ruby
class UsersController < ApiController
  TodoOrDie("delete after JS app has propagated", by: "2019-02-04")
  def show
    redirect_to root_path
  end
end
```

Nothing will happen at all until February 4th, at which point the gem will
raise an error whenever this class is loaded until someone deals with it.

### What kind of error?

It depends on whether you're using [Rails](https://rubyonrails.org) or not.

#### When you're writing Real Ruby

If you're not using Rails (i.e. `defined?(Rails)` is false), then the gem will
raise a `TodoOrDie::OverdueError` whenever a TODO is overdue. The message looks
like this:

```
TODO: "Visit Wisconsin" came due on 2016-11-09. Do it!
```

#### When `Rails` is a thing

If TodoOrDie sees that `Rails` is defined, it'll assume you probably don't want
this tool to run outside development and test, so it'll log the error message to
`Rails.logger.warn` in production (while still raising the error in development
and test).

### Wait, won't sprinkling time bombs throughout my app ruin my weekend?

Sure will! It's "TODO or Die", not "TODO and Remember to Pace Yourself".

Still, someone will probably get mad if you break production because you forgot
to follow through on removing an A/B test, so I'd [strongly recommend you read
what the default hook actually does](lib/todo_or_die.rb#L8-L16) before this gem
leads to you losing your job. (Speaking of, please note the lack of any warranty
in `todo_or_die`'s [license](LICENSE.txt).)

To appease your boss, you may customize the gem's behavior by passing in your
own `call`'able lambda/proc/dingus like this:

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
ignored. (You can restore the default hook with `TodoOrDie.reset`).

## When is this useful?

This gem may come in handy whenever you know the code _will_ need to change,
but it can't be changed just yet, and you lack some other reliable means of
ensuring yourself (or your team) will actually follow through on making the
change later.

This is a good time to recall [LeBlanc's
Law](https://www.quora.com/What-resources-could-I-read-about-Leblancs-law),
which states that `Later == Never`. Countless proofs of this theorem have been
reproduced by software teams around the world. Some common examples:

* A feature flag was added to the app a long time ago, but the old code path is
  still present, even after the flag had been enabled for everyone. Except now
  there's also a useless `TODO: delete` comment to keep it company
* A failing test was blocking the build and someone felt an urgent pressure to
  deploy the app anyway. So, rather than fix the test, Bill commented it out
  "for now"
* You're a real funny guy and you think it'd be hilarious to make a bunch of
  Aaron's tests start failing on Christmas morning

## Pro-tip

Cute Rails date helpers are awesome, but don't think you're going to be able to
do this and actually accomplish anything:

```ruby
TodoOrDie("Update after APIv2 goes live", 2.weeks.from_now)
```

It will never be two weeks from now.
