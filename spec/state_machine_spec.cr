require "spec"
require "../src/state_machine"

machine = StateMachine.new(:pending)

machine.when(:confirm, { pending:   :confirmed })
machine.when(:ignore,  { pending:   :ignored })
machine.when(:reset,   { confirmed: :pending, ignored: :pending })

# callbacks

flag_state = ""
current_state = ""

machine.on(:pending)   { flag_state = "Pending" }
machine.on(:confirmed) { flag_state = "Confirmed" }
machine.on(:any)       { current_state = flag_state }

describe StateMachine do
  context "introspection" do
    it "returns an array with defined events" do
      machine.events.should eq([:confirm, :ignore, :reset])
    end

    it "returns an array with defined states" do
      machine.states.should eq([:pending, :confirmed, :ignored])
    end

    it "returns true if compared state is equal to current" do
      (machine == :pending).should be_true
    end

    it "returns false if compared state is not equal to current" do
      (machine == :confirmed).should be_false
    end
  end

  context "transitions" do
    it "defines initial state" do
      machine.state.should eq(:pending)
    end

    it "raises an error if invalid event is triggered" do
      expect_raises StateMachine::InvalidEvent do
        machine.trigger?(:invalid)
      end
    end

    it "preserves the state if transition is not possible" do
      machine.trigger?(:reset).should be_false
      machine.trigger(:reset).should be_false
      machine.state.should eq(:pending)
    end

    it "changes the state if transition is possible" do
      machine.trigger?(:confirm).should be_true
      machine.trigger(:confirm).should be_true
      machine.state.should eq(:confirmed)
    end

    it "discerns multiple transitions" do
      machine.trigger(:confirm)
      machine.state.should eq(:confirmed)

      machine.trigger(:reset)
      machine.state.should eq(:pending)

      machine.trigger(:ignore)
      machine.state.should eq(:ignored)

      machine.trigger(:reset)
      machine.state.should eq(:pending)
    end

    it "raises an error if event is triggered from/to a non complatible state" do
      expect_raises StateMachine::InvalidState do
        machine.trigger!(:reset)
      end
    end
  end

  context "callbacks" do
    it "executes callbacks when entering a state" do
      machine.trigger(:confirm)
      flag_state.should eq("Confirmed")

      machine.trigger(:reset)
      flag_state.should eq("Pending")
    end

    it "executes the callback on any transition" do
      machine.trigger(:confirm)
      current_state.should eq("Confirmed")

      machine.trigger(:reset)
      current_state.should eq("Pending")
    end

    it "passing the event name to the callbacks" do
      event_name = nil

      machine = StateMachine.new(:pending)
      machine.when(:confirm, { pending: :confirmed })

      machine.on(:confirmed) do |event|
        event_name = event
      end

      machine.trigger(:confirm)

      event_name.should eq(:confirm)
    end
  end

  context "types" do
    it "supports types other than Symbol for states" do
      machine = StateMachine.new(0)
      machine.when(:confirm, { 0 => 1 })

      machine.state.should eq(0)

      machine.trigger(:confirm)
      machine.state.should eq(1)
    end
  end
end
