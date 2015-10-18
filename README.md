# spec2 [![Build Status](https://travis-ci.org/waterlink/spec2.cr.svg)](https://travis-ci.org/waterlink/spec2.cr)

Enhanced `spec` testing library for [Crystal](http://crystal-lang.org/).

## Example

```crystal
Spec2.describe Greeting do
  subject { Greeting.new }

  describe "#greet" do
    context "when name is world"
      let(name) { "world" }

      it "greets the world" do
        expect(subject.greet(name)).to eq("Hello, world")
      end
    end
  end
end
```

## Installation

Add it to `shard.yml`

```yml
dependencies:
  spec2:
    github: waterlink/spec2.cr
    branch: master
```

## Goals

- No global scope pollution
- No `Object` pollution
- Ability to run examples in random order
- Ability to specify `before` and `after` blocks for example
  group
- Ability to define `let`, `let!`, `subject` and `subject!`
  for example group

## Roadmap

- [x] Allow nested `describe` and `context`.
- [x] Ability to enable `should` syntax for legacy codebases.
- [x] Proper `Reporter` protocol + built-in implementations + ability to
  configure it.
- [x] Proper `Runner` protocol + built-in implementations + ability to
  configure it.
- [x] Proper `Order` protocol + built-in implementations + ability to configure
  it.
- [x] Proper `Output` protocol + built-in implementations + ability to
  configure it.
- [x] Proper `Matcher` protocol + ability to register them.
- [ ] Matcher protocol.
- [ ] Configuration through CLI interface.
- [ ] Filters.

## Usage

```crystal
require "spec2"
```

### Top-level describe

```crystal
Spec2.describe MySuperLibrary do
  describe Greeting do
    # .. example groups and examples here ..
  end
end
```

If you have test suite written for `Spec` and you don't want to prefix each
top-level describe with `Spec2.`, you can just include `Spec::Macros` globally:

```crystal
include Spec2::GlobalDSL

# and then:
describe Greeting do
  # ...
end
```

### `Expect` syntax

```crystal
expect(greeting.for("john")).to eq("hello, john")
```

If you have big codebase that runs on `Spec`, you can use this to
enable `#should` and `#should_not` on `Object`:

```crystal
Spec2.enable_should_on_object
```

### List of builtin matchers

- `eq("hello, world")` - asserts actual is equal to expected
- `raise_error(ErrorClass [, message_matcher])` - checks if block raises expected error
- `be(42)` - asserts actual is the same as expected

### Random order

```crystal
Spec2.random_order

# this is what happens under the hood
Spec2.configure_order(Spec2::Orders::Random)
```

To configure your own custom order you can use:

```crystal
Spec2.configure_order(MyOrder)
```

Class `MyOrder` should implement `Order` protocol ([see it here](src/order.cr)).
See also [a random order implementation](src/orders/random.cr).

### No color mode

```crystal
Spec2.nocolor

# this is what happens under the hood
Spec2.configure_output(Spec2::Outputs::Nocolor)
```

To configure your own custom output you can use:

```crystal
Spec2.configure_output(MyOutput)
```

Class `MyOutput` should implement `Output` protocol ([see it here](src/output.cr)).
See also [a default colorful output implementation](src/outputs/default.cr).

### Documentation reporter

```crystal
Spec2.doc

# this is what happens under the hood
Spec2.configure_reporter(Spec2::Reporters::Doc)
```

To configure your own custom reporter you can use:

```crystal
Spec2.configure_reporter(MyReporter)
```

Class `MyReporter` should implement `Reporter` protocol ([see it here](src/reporter.cr)).
See also [a default reporter implementation](src/reporters/default.cr).

### Configuring custom Runner

```crystal
Spec2.configure_runner(MyRunner)
```

Class `MyRunner` should implement `Runner` protocol ([see it here](src/runner.cr)).
See also [a default runner implementation](src/runners/default.cr).

### `before`

`before` - register a hook that is run before any example in current and all
nested contexts.

```crystal
before { .. do some stuff .. }
```

### `after`

`after` - register a hook that is run after any successful example in current
and all nested contexts.

```crystal
after { .. do some stuff .. }
```

### `let`

`let(name) { value }` - register a binding of certain `value` to `name`. Lazy:
provided block will only be evaluated when needed in example and only once per
example.

```crystal
let(answer) { 42 }

it "is correct answer" do
  expect(answer).to eq(42)
end
```

### `let!`

`let(name) { value }` - register a binding of certain `value` to `name`. It is
not lazy: provided block will be evaluated before each example exactly once.

```crystal
let!(answer) { 42 }

it "is correct answer" do
  expect(answer).to eq(42)
end
```

### `subject`

`subject { value }` - register a subject of your test with provided `value`.
Lazy.

```crystal
subject { Stuff.new }

it "works" do
  expect(subject.answer).to eq(42)
end
```

`subject(name) { value }` - registers a named subject of your test with
provided `value` with provided `name`. Lazy.

```crystal
subject(stuff) { Stuff.new }

it "works" do
  expect(stuff.answer).to eq(42)
end
```

### `subject!`

`subject! { value }` - register a subject of your test with provided `value`.
It is not lazy.

```crystal
subject! { Stuff.new }

it "works" do
  expect(subject.answer).to eq(42)
end
```

`subject!(name) { value }` - registers a named subject of your test with
provided `value` with provided `name`. It is not lazy.

```crystal
subject!(stuff) { Stuff.new }

it "works" do
  expect(stuff.answer).to eq(42)
end
```

### Custom matchers

First, define your matcher implementing [this protocol](src/matcher.cr):

```crystal
class MyMatcher < Spec2::Matcher
  def initialize(@expected, @stuff)
  end

  def match(@actual)
    # return true or false here
  end

  def failure_message
    "Expected to be valid #{@stuff.inspect}.
    Expected: #{@expected.inspect}.
    Actual:   #{@actual.inspect}."
  end

  def failure_message_when_negated
    "Expected to be invalid #{@stuff.inspect}.
    Expected: #{@expected.inspect}.
    Actual:   #{@actual.inspect}."
  end

  def description
    "(stuff in #{@expected} #{stuff})"
  end
end
```

And then, register shortcut helper method to use your matcher.

```crystal
Spec2.register_matcher(stuff) do |stuff, expected|
  MyMatcher.new(expected, stuff)
end
```

And use it:

```crystal
describe "stuff" do
  it "is valid stuff" do
    expect(something).to stuff(some_stuff, "expected stuff")
  end
end
```

## Development

After you forked the repo:

- run `crystal deps` to install dependencies
- run `crystal spec` to see if tests are green
- apply TDD to implement your feature/fix/etc

## Contributing

1. Fork it ( https://github.com/waterlink/spec2.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator, maintainer
