module Strategies
  class ScaleStrategy < ChoiceStrategy
    def render(item)
      # Render scale (numeric sequence of options)
      item.alternatives.map { |alt| "<option value='#{alt}'>#{alt}</option>" }.join
    end

    def validate(item)
      # Validate that alternatives are numeric
      unless item.alternatives.all? { |alt| alt.match?(/^\d+$/) }
        item.errors.add(:alternatives, "must be numeric for scale items")
      end
    end
  end
end