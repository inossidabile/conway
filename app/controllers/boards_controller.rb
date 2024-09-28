class BoardsController < ApplicationController
  def create
    @board_params = board_params
    @board_params = @board_params.merge({ life_locations: generate_life_locations }) if @board_params[:life_locations].blank?
    render json: { board: BoardEvaluator.schedule(Board.create!(@board_params)) }
  end

  def show
    render json: { board: Board.find(params[:id]).as_json(include: :last_iteration) }
  end

  def index
    render json: { boards: Board.pluck(:id) }
  end

  private

  def generate_life_locations
    Board.each_location(board_params[:width], board_params[:height]).map do |x, y|
      "(#{x.to_f}, #{y.to_f})" if rand(2) == 1
    end.compact
  end

  def board_params
    params.require(:board).permit(:height, :width, :max_iterations, life_locations: []).tap do |p|
      p.require([ :height, :width ])
    end
  end
end
