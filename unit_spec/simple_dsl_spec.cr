require "./spec_helper"

module SimpleDSLSpec
  @@__spec2_active_context : ::Spec2::Context?

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something" do
    evt << :described_something
  end

  describe "describe statement" do
    it "creates a context" do
      Spec2::Context.contexts[0].what
        .should H.eq("something")
    end

    it "runs content of context" do
      evt.should H.eq([:described_something])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.context "when something" do
    evt << :context_when_something
  end

  describe "context statement" do
    it "creates a context" do
      Spec2::Context.contexts[0].what
        .should H.eq("when something")

      Spec2::Context.contexts[0].description
        .should H.eq("when something")
    end

    it "runs content of context" do
      evt.should H.eq([:context_when_something])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.context "something with inner context" do
    evt << :context_when_something

    context "when something else" do
      evt << :context_when_something_else
    end
  end

  describe "inner context" do
    it "creates a context" do
      Spec2::Context.contexts[0].what
        .should H.eq("something with inner context")

      Spec2::Context.contexts[0].description
        .should H.eq("something with inner context")
    end

    it "creates an inner context" do
      Spec2::Context.contexts[0].contexts[0].what
        .should H.eq("when something else")

      Spec2::Context.contexts[0].contexts[0].description
        .should H.eq("something with inner context when something else")
    end

    it "runs content of context and inner context" do
      evt.should H.eq([:context_when_something, :context_when_something_else])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with it" do
    evt << :described_something

    it "works" do
      H.evt << :it_works
    end
  end

  describe "it statement" do
    example = Spec2::Context.contexts[0].examples[0]

    it "defines an example" do
      example.what.should H.eq("works")

      example.description.should H.eq("something with it works")
    end

    it "does not execute block right away" do
      evt.should H.eq([:described_something])
    end

    it "is possible to execute a block" do
      example.run
      evt.should H.eq([:described_something, :it_works])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with pending" do
    evt << :described_something

    pending "pending functionality" do
      H.evt << :it_is_pending
    end
  end

  describe "pending statement" do
    example = Spec2::Context.contexts[0].examples[0]

    it "defines an example" do
      example.what.should H.eq("pending functionality")

      example.description.should H.eq("something with pending pending functionality")
    end

    it "does not execute block right away" do
      evt.should H.eq([:described_something])
    end

    it "does not execute block when run" do
      example.run
      evt.should H.eq([:described_something])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with let" do
    evt << :described_something

    let(greeting) { H.evt << :define_let; "hello world" }

    it "works" do
      H.evt << :it_works
      greeting.should H.eq("hello world")
    end
  end

  describe "let statement" do
    example = Spec2::Context.contexts[0].examples[0]

    it "does not execute let block right away" do
      evt.should H.eq([:described_something])
    end

    it "executes let and it blocks once when run" do
      example.run
      evt.should H.eq([
        :described_something,
        :it_works,
        :define_let,
      ])
    end

    it "can execute example multiple times, but not let" do
      example.run
      example.run
      example.run
      evt.should H.eq([
        :described_something,
        :it_works,
        :define_let,
        :it_works,
        :it_works,
        :it_works,
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with let bang" do
    let!(greeting) { H.evt << :define_let; "hello world" }

    it "does not call let" do
      H.evt << :it_does_not
    end

    it "calls let" do
      H.evt << :it_calls
      greeting.should H.eq("hello world")
    end
  end

  describe "let! statement" do
    does_not = Spec2::Context.contexts[0].examples[0]
    calls = Spec2::Context.contexts[0].examples[1]

    it "does not execute let block right away" do
      evt.should H.eq([] of Symbol)
    end

    it "executes let block when is not used" do
      does_not.run
      evt.should H.eq([
        :define_let,
        :it_does_not,
      ])
    end

    it "executes let block when used" do
      calls.run
      evt.should H.eq([
        :define_let,
        :it_does_not,
        :define_let,
        :it_calls,
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "inherited lets" do
    let(greeting) { H.evt << :define_let; "#{word} #{name}" }

    context "when greeting the world" do
      let(word) { "hello" }
      let(name) { "world" }

      it "is a first program" do
        greeting.should H.eq("hello world")
      end
    end

    context "when greeting an acquaintance" do
      let(word) { "hey" }
      let(name) { "John" }

      it "is an informal greeting" do
        greeting.should H.eq("hey John")
      end

      context "when greeter is lazy" do
        let(greeting) { "Hi!" }

        it "is a lazy form of greeting" do
          greeting.should H.eq("Hi!")
        end
      end

      context "when acquaintance is Joe" do
        let(name) { "Joe" }

        it "is an informal greeting for Joe" do
          greeting.should H.eq("hey Joe")
        end
      end

      context "when greeter is nice" do
        let(greeting) { "#{super}! How are you?" }

        it "is a nice form of greeting" do
          greeting.should H.eq("hey John! How are you?")
        end
      end
    end
  end

  describe "inherited lets" do
    examples = [
      ::Spec2::Context.contexts[0].contexts[0].examples[0],
      ::Spec2::Context.contexts[0].contexts[1].examples[0],
      ::Spec2::Context.contexts[0].contexts[1].contexts[0].examples[0],
      ::Spec2::Context.contexts[0].contexts[1].contexts[1].examples[0],
      ::Spec2::Context.contexts[0].contexts[1].contexts[2].examples[0],
    ]

    it "passes" do
      examples.each &.run
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with subject" do
    subject { "hello world" }

    it "works" do
      subject.should H.eq("hello world")
    end
  end

  describe "subject statement" do
    example = ::Spec2::Context.contexts[0].examples[0]

    it "works as let(subject)" do
      example.run
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with subject bang" do
    subject! { H.evt << :subject_defined; "hello world" }

    it "does not" do
      H.evt << :does_not
    end

    it "calls" do
      H.evt << :calls
      subject.should H.eq("hello world")
    end
  end

  describe "subject bang statement" do
    does_not = ::Spec2::Context.contexts[0].examples[0]
    calls = ::Spec2::Context.contexts[0].examples[1]

    it "works as let!(subject)" do
      evt.should H.eq([] of Symbol)

      does_not.run
      evt.should H.eq([:subject_defined, :does_not])

      calls.run
      evt.should H.eq([
        :subject_defined,
        :does_not,
        :subject_defined,
        :calls,
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "named subject" do
    subject(greeting) { "hello world" }

    it "works" do
      greeting.should H.eq("hello world")
    end
  end

  describe "named subject statement" do
    example = ::Spec2::Context.contexts[0].examples[0]

    it "works as let(name)" do
      example.run
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "named subject bang" do
    subject!(greeting) { H.evt << :subject_defined; "hello world" }

    it "does not" do
      H.evt << :does_not
    end

    it "calls" do
      H.evt << :calls
      greeting.should H.eq("hello world")
    end
  end

  describe "named subject bang statement" do
    does_not = ::Spec2::Context.contexts[0].examples[0]
    calls = ::Spec2::Context.contexts[0].examples[1]

    it "works as let!(subject)" do
      evt.should H.eq([] of Symbol)

      does_not.run
      evt.should H.eq([:subject_defined, :does_not])

      calls.run
      evt.should H.eq([
        :subject_defined,
        :does_not,
        :subject_defined,
        :calls,
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with before and after" do
    evt << :described_something

    let(stuff) { 42 }

    after { H.evt << :after_a }
    before { H.evt << :before_a }
    before { H.evt << :"before_b" if stuff == 42 }
    after { H.evt << :after_b }
    before { H.evt << :before_c }
    after { H.evt << :after_c }

    it "works" do
      H.evt << :works
    end

    context "when stuff is not 42" do
      let(stuff) { super - 1 }

      before { H.evt << :inner_before }
      after { H.evt << :inner_after }

      it "works too" do
        H.evt << :works_too
      end
    end
  end

  describe "before and after" do
    examples = [
      ::Spec2::Context.contexts[0].examples[0],
      ::Spec2::Context.contexts[0].contexts[0].examples[0],
    ]

    it "runs hooks in right order" do
      evt.should H.eq([:described_something])

      examples.each &.run

      evt.should H.eq([
        :described_something,

        :before_a,
        :before_b,
        :before_c,
        :works,
        :after_a,
        :after_b,
        :after_c,

        :before_a,
        :before_c,
        :inner_before,
        :works_too,
        :after_a,
        :after_b,
        :after_c,
        :inner_after,
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with after after failure" do
    H.evt << :root

    after { H.evt << :it_is_cleaning_time }

    it "fails" do
      H.evt << :before_failure
      raise "I fail"
    end
  end

  describe "after block when example failed" do
    example = ::Spec2::Context.contexts[0].examples[0]

    it "still gets executed" do
      expect_raises do
        example.run
      end

      H.evt.should eq([
        :root,
        :before_failure,
        :it_is_cleaning_time
      ])
    end
  end

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "uniqueness of context tree" do
    evt << :root

    context "context a" do
      before { H.evt << :context_a }

      it "works" do
        H.evt << :works
      end
    end

    context "inner" do
      context "context a" do
        before { H.evt << :inner_context_a }

        it "works too" do
          H.evt << :works_too
        end
      end

      context "random context inside" do
      end
    end
  end

  describe "uniqueness of context tree" do
    examples = [
      ::Spec2::Context.contexts[0].contexts[0].examples[0],
      ::Spec2::Context.contexts[0].contexts[1].contexts[0].examples[0],
    ]

    it "distinguishes contexts with same what, but different parents" do
      examples.map &.run
      evt.should H.eq([
        :root,
        :context_a,
        :works,
        :inner_context_a,
        :works_too,
      ])
    end
  end
end
