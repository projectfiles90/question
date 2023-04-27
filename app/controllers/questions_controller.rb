class QuestionsController < ApplicationController
  def index
    questions = Question.all
    render json: questions, status: :ok
  end

  def create
    question = Question.new(question_params)
    if question.save
      render json: question, status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    question = Question.find(params[:id])
    render json: shuffled_question(question), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Question not found" }, status: :not_found
  end

  def update
    question = Question.find(params[:id])
    if question.update(question_params)
      render json: shuffled_question(question), status: :ok
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Question not found" }, status: :not_found
  end


  def destroy
    question = Question.find(params[:id])
    question.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Question not found" }, status: :not_found
  end

  private

  def question_params
    params.require(:question).permit(:question_text, :option1, :option2, :option3, :option4, :correct_option)
  end

  def shuffled_question(question)
    options = [question.option1, question.option2, question.option3, question.option4].shuffle
    {
      id: question.id,
      question_text: question.question_text,
      option1: options[0],
      option2: options[1],
      option3: options[2],
      option4: options[3],
      correct_option: question.correct_option,
      created_at: question.created_at,
      updated_at: question.updated_at
    }
  end
end
