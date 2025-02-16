class Item < ApplicationRecord
  before_create :set_seq
  belongs_to :questionnaire # each item belongs to a specific questionnaire
  has_many :answers, dependent: :destroy
  has_many :choices, dependent: :destroy
  attr_accessor :choice_strategy
  
  validates :seq, presence: true, numericality: true # sequence must be numeric
  validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # text content must be provided
  validates :question_type, presence: true # user must define the item type
  validates :break_before, presence: true

  def scorable?
    false
  end
    
  def set_seq
    self.seq = questionnaire.items.size + 1
  end

  def as_json(options = {})
      super(options.merge({
                            only: %i[txt weight seq question_type size alternatives break_before min_label max_label created_at updated_at],
                            include: {
                              questionnaire: { only: %i[name id] }
                            }
                          })).tap do |hash|
      end
  end

  def strategy
    case question_type
    when 'dropdown'
      self.choice_strategy = Strategies::DropdownStrategy.new
    when 'multiple_choice'
      self.choice_strategy = Strategies::MultipleChoiceStrategy.new
    when 'scale'
      self.choice_strategy = Strategies::ScaleStrategy.new
    else
      raise "Unknown item type: #{question_type}"
    end
  end

  # Use strategy to render the item
  def render
    strategy.render(self)
  end

  # Use strategy to validate the item
  def validate_item
    strategy.validate(self)
  end
end