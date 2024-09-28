class EvaluateBoardJob
  include Sidekiq::Job

  def perform(board_id)
    BoardEvaluator.new(board_id).process
  end
end
