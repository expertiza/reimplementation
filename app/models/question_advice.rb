class QuestionAdvice < ApplicationRecord
    belongs_to :item
    def self.export_fields(_options)
      QuestionAdvice.columns.map(&:name)
    end
  
    def self.export(csv, parent_id, _options)
      questionnaire = Questionnaire.find(parent_id)
      questionnaire.items.each do |item|
        QuestionAdvice.where(question_id: item.id).each do |advice|
          csv << advice.attributes.values
        end
      end
    end
  
    def self.to_json_by_question_id(question_id)
      question_advices = QuestionAdvice.where(question_id: question_id).order(:id)
      question_advices.map do |advice|
        { score: advice.score, advice: advice.advice }
      end
    end
  end