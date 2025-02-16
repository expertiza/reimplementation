module Strategies
  class DropdownStrategy < ChoiceStrategy
    def render(item)
      # render the dropdown options as HTML
      item.alternatives.map { |alt| "<option value='#{alt}'>#{alt}</option>" }.join
    end

    def validate(item)
      # Validate that alternatives are non-empty
      if item.alternatives.empty?
        item.errors.add(:alternatives, "can't be empty for a dropdown")
      end
    end
  end
end