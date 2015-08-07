# spec2

Enhanced `spec` testing library for [Crystal](http://crystal-lang.org/).

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "waterlink/spec2.cr"
end
```

## Goals

- [x] No global scope pollution
- [x] No `Object` pollution
- [x] Ability to run examples in random order
- [ ] Ability to specify `before` and `after` blocks for example
  group
- [ ] Ability to define `let`, `let!`, `subject` and `subject!`
  for example group

## Usage

```crystal
require "spec2"
```

### Top-level describe

```crystal
module MySuperLibrary::Specs
  include Spec2::Macros

  describe Greeting do
    # .. example groups and examples here ..
  end
end
```

If you have test suite written for `Spec` and you don't want to put each
top-level describe in its own module, you can use just include `Spec::Macros`
globally:

```crystal
include Spec2::Macros

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
enable `#should` on `Object`:

```crystal
# TODO
Spec2.enable_should_on_object
```

### Random order runner

```crystal
Spec2.random_order

# this is what happens under the hood
# TODO
Spec2.configure_runner(Spec2::RandomRunner)
```

### `before`, `after`, `let` and others

TODO

Full fledged example:

```crystal
describe Greeting do
  subject(:greeting) { Greeting.new(greeting_exclamation) }
  subject!(:thing) { puts "=== subject with bang ===" }

  let(:greeting_exclamation) { "hello" }
  let(:name) { "world" }

  let!(:something) { puts "=== let with bang ===" }

  before do
    puts "=== before example ==="
  end

  after do
    puts "=== after example ==="
  end

  describe "#for" do
    subject(:greeting_string) { greeting.for(name) }

    it "greets provided person" do
      expect(:greeting_string).to eq("hello, world")
    end

    context "when name is john" do
      let(:name) { "john" }

      it "greets john" do
        expect(:greeting_string).to eq("hello, john")
      end
    end

    context "when greeting exclamation is different" do
      let(:greeting_exclamation) { "hallo" }

      it "greets world with different exclamation" do
        expect(greeting_string).to eq("hallo, world")
      end
    end
  end
end
```

Output:

```
Greeting
  #for
=== before example ===
=== subject with bang ===
=== let with bang ===
    greets provided person
=== after example ===
    when name is john
=== before example ===
=== subject with bang ===
=== let with bang ===
      greets john
=== after example ===
    when greeting exclamation is different
=== before example ===
=== subject with bang ===
=== let with bang ===
      greets world with different exclamation
=== after example ===
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
