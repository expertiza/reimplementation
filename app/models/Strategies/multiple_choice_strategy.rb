module Strategies
  class MultipleChoiceStrategy < ChoiceStrategy
    def render(item)
      # Render radio buttons for multiple choice
      item.alternatives.map { |alt| "<input type='radio' name='item_#{item.id}' value='#{alt}'> #{alt}</input>" }.join
    end

    def validate(item)
      # Validate that alternatives are non-empty
      if item.alternatives.empty?
        item.errors.add(:alternatives, "can't be empty for multiple choice")
      end
    end
  end
end