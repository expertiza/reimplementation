class Api::V1::QuestionnairesController < ApplicationController

  # GET /api/v1/questionnaires/view
  def view
    @questionnaires = Questionnaire.order(:id)
    render json: @questionnaires
  end

  # GET /api/v1/questionnaires/show/:id
  def show
    begin
      @questionnaire = Questionnaire.find(params[:id])
      render json: @questionnaire
    rescue
      msg = "No such Questionnaire exists."
      render json: msg
    end
  end

  # POST /api/v1/questionnaires/copy/:id
  def copy
    begin
      questionnaire = Questionnaire.find(params[:id])
      puts "IN COPY"
      puts params.inspect
      puts questionnaire
    rescue
      msg = "No such Questionnaire to copy."
      render json: msg
    end
    copy_questionnaire = Questionnaire.copy_questionnaire_details(questionnaire.id)
    # Are the next 3 lines needed?
    p_folder = TreeFolder.find_by(name: questionnaire.display_type)
    parent = FolderNode.find_by(node_object_id: p_folder.id) if !p_folder.nil?
    QuestionnaireNode.find_or_create_by(parent_id: parent.id, node_object_id: questionnaire.id) if !parent.nil?
    success_msg = "Copy of questionnaire #{questionnaire.name} has been created successfully."
    render json: success_msg
  rescue StandardError
    error_msg = 'The questionnaire was not able to be copied. Error:' + $ERROR_INFO.to_s
    render json: error_msg
    
  end

  # POST /api/v1/questionnaires/toggle_access/:id
  def toggle_access
    begin
      questionnaire = Questionnaire.find(params[:id])
    rescue
      msg = "No such Questionnaire exists."
      render json: msg
    end
    questionnaire.private = !questionnaire.private
    questionnaire.save
    access = questionnaire.private == true ? 'private' : 'public'
    success_msg = "The questionnaire \"#{questionnaire.name}\" has been successfully made #{access}."
    render json: success_msg
  end

  # DELETE /api/v1/questionnaires/delete/:id
  def delete
    @questionnaire = Questionnaire.find(params[:id])
    begin
      name = @questionnaire.name
      # if this rubric is used by some assignment, flash error
      unless @questionnaire.assignments.empty?
        error_msg = "The assignment #{@questionnaire.assignments.first.try(:name)} uses this questionnaire."
        render json: error_msg
      end
      questions = @questionnaire.questions
      # if this rubric had some answers, flash error
      questions.each do |question|
        unless question.answers.empty?
          error_msg = 'There are responses based on this rubric, we suggest you do not delete it.' 
          render json: error_msg
        end
      end
      questions.each do |question|
        advices = question.question_advices
        advices.each(&:delete)
        question.delete
      end
      # questionnaire_node = @questionnaire.questionnaire_node
      # questionnaire_node.delete
      @questionnaire.delete
      success_msg = "The questionnaire \"#{name}\" has been successfully deleted."
      render json: success_msg
    rescue StandardError => e
      render json: e.message
    end
  end

  private

  def questionnaire_params
    params.permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end

end
