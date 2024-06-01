class Api::V1::QuestionsController < ApplicationController
  def create
    questions = QuestionFacade.create_questions(params[:topic], params[:number_of_questions])
    if questions.is_a?(String)
      handle_service_error(questions)
    else
      render json: QuestionSerializer.new(questions), status: :created
    end
  rescue StandardError => e
    handle_internal_server_error(e)
  end
end