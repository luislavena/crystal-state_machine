class StateMachine(T)
  class InvalidEvent < ArgumentError; end
  class InvalidState < ArgumentError; end

  getter :state

  def initialize(@state : T) : Void
    @transitions_for = Hash(Symbol, Hash(T, T)).new
    @callbacks = Hash(T | Symbol, Array(Symbol ->)).new { |hash, key|
      hash[key] = Array(Symbol ->).new
    }
  end

  def ==(other : T) : Bool
    @state == other
  end

  def events : Array(Symbol | String)
    @transitions_for.keys
  end

  def on(key : T | Symbol, &block : Symbol ->) : Void
    @callbacks[key].push block
  end

  def states : String
    states = Set(T).new

    @transitions_for.each_value do |transitions|
      states.merge transitions.keys
      states.merge transitions.values
    end

    states.to_a
  end

  def trigger(event : Symbol) : Bool
    if trigger?(event)
      @state = @transitions_for[event][@state]

      (@callbacks[@state] + @callbacks[:any]).each do |callback|
        callback.call(event)
      end

      true
    else
      false
    end
  end

  def trigger!(event : Symbol) : Bool
    if trigger(event)
      true
    else
      raise InvalidState.new("Event '#{event}' not valid from state '#{@state}'")
    end
  end

  def trigger?(event : Symbol) : Bool
    raise InvalidEvent.new("Invalid event '#{event}'") unless @transitions_for.has_key?(event)

    @transitions_for[event].has_key?(@state)
  end

  def when(event : Symbol, transitions : NamedTuple) : Hash
    @transitions_for[event] = transitions.to_h
  end
end
