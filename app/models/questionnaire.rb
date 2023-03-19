class Questionnaire < ApplicationRecord
  has_many :questions, dependent: :destroy
  belongs_to :instructor # the creator of this questionnaire
  has_many :assignment_questionnaires, dependent: :destroy
  has_many :assignments, through: :assignment_questionnaires
  has_one :questionnaire_node, foreign_key: 'node_object_id', dependent: :destroy, inverse_of: :questionnaire

  validates :name, presence: true, uniqueness: {message: 'Questionnaire names must be unique.'}
  validates :min_question_score, numericality: true,
            comparison: { greater_than_or_equal_to: 0, message: 'The minimum question score must be a positive integer.'}
  validates :max_question_score, numericality: true
  # validations to ensure max_question_score is  greater than both min_question_score and 0
  validates_comparison_of :max_question_score, {greater_than: :min_question_score, message: 'The minimum question score must be less than the maximum.'}
  validates_comparison_of :max_question_score, {greater_than: 0, message: 'The maximum question score must be a positive integer greater than 0.'}

  DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any questionnaire question
  DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any questionnaire question
  DEFAULT_QUESTIONNAIRE_URL = 'http://www.courses.ncsu.edu/csc517'.freeze
  QUESTIONNAIRE_TYPES = ['ReviewQuestionnaire',
                         'MetareviewQuestionnaire',
                         'Author FeedbackQuestionnaire',
                         'AuthorFeedbackQuestionnaire',
                         'Teammate ReviewQuestionnaire',
                         'TeammateReviewQuestionnaire',
                         'SurveyQuestionnaire',
                         'AssignmentSurveyQuestionnaire',
                         'Assignment SurveyQuestionnaire',
                         'Global SurveyQuestionnaire',
                         'GlobalSurveyQuestionnaire',
                         'Course SurveyQuestionnaire',
                         'CourseSurveyQuestionnaire',
                         'Bookmark RatingQuestionnaire',
                         'BookmarkRatingQuestionnaire',
                         'QuizQuestionnaire'].freeze
  #has_paper_trail

  # Returns true if this questionnaire contains any true/false questions, otherwise returns false
  def has_true_false_questions
    questions.any? { |question| question.type == 'Checkbox'}
  end

  # actions that will occur if questionnaire is deleted
  def delete
    # associated question records and questionnaire node record have dependent: :destroy configured on active record association
    assignments.each do |assignment|
      raise "The assignment #{assignment.name} uses this questionnaire.
            Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
    end
    destroy
  end

  # finds the max possible score by adding the weight of each question together and multiplying that sum by the questionnaire's max question score,
  # which determines the max possible score for each question associated to the questionnaires
  def max_possible_score
    questions_weight_sum = questions.sum { |question| question.weight}
    max_score = questions_weight_sum * max_question_score
  end
end
