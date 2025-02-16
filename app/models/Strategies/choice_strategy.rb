module Strategies
  class ChoiceStrategy
    def render(item)
      raise NotImplementedError, "You must implement the render method"
    end

    def validate(item)
      raise NotImplementedError, "You must implement the validate method"
    end
  end
end
  