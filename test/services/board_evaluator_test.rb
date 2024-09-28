require "test_helper"

class BoardTest < ActiveSupport::TestCase
  def test_within_board
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 1)" ])

    assert BoardEvaluator::Cell.within_board?(board, 0, 0)
    assert BoardEvaluator::Cell.within_board?(board, 9, 9)
    assert_not BoardEvaluator::Cell.within_board?(board, 10, 0)
    assert_not BoardEvaluator::Cell.within_board?(board, 0, 10)
  end

  def test_neighbors
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 1)" ])

    assert_equal [ [ 0, 1 ], [ 1, 0 ], [ 1, 1 ] ], BoardEvaluator::Cell.new(board, 0, 0, true).neighbors_locations
    assert_equal [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ], BoardEvaluator::Cell.new(board, 2, 2, true).neighbors_locations
    assert_equal [ [ 8, 8 ], [ 8, 9 ], [ 9, 8 ] ], BoardEvaluator::Cell.new(board, 9, 9, true).neighbors_locations
  end

  def test_iteration_idempotence
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 1)" ])

    assert_difference -> { board.iterations.reload.count } => 1 do
      BoardEvaluator.new(board.id)
    end
  end

  def test_life_locations_set
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 1)", "(5, 3)" ])
    BoardEvaluator.new(board.id)

    assert_equal 1, board.iterations.count
    assert_equal Set.new([ "0/1", "5/3" ]), BoardEvaluator::LocationsMap.new(board, board.iterations.last).life_locations_set
  end

  def test_stabilizing_tick
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 0)", "(0, 1)", "(1, 0)", "(1, 1)" ])

    evaluator = BoardEvaluator.new(board.id)

    assert_difference -> { board.iterations.reload.count } => 1 do
      evaluator.tick!
      evaluator.tick!
    end

    assert board.reload.stabilized?
  end

  def test_inconclusive_tick
    board = Board.create!(height: 10, width: 10, life_locations: [ "(0, 0)", "(0, 1)", "(1, 0)", "(1, 1)", "(0, 2)" ])

    evaluator = BoardEvaluator.new(board.id)

    assert_difference -> { board.iterations.reload.count } => 1 do
      evaluator.tick!
    end

    assert board.reload.evaluating?
    assert_equal [ { "x"=>0.0, "y"=>0.0 }, { "x"=>0.0, "y"=>2.0 }, { "x"=>1.0, "y"=>0.0 }, { "x"=>1.0, "y"=>2.0 } ], board.iterations.last.reload.life_locations.as_json
  end

  def test_failed_process
    board = Board.create!(height: 10, width: 10, max_iterations: 2, life_locations: [ "(0, 0)", "(0, 1)", "(1, 0)", "(1, 1)", "(0, 2)" ])

    evaluator = BoardEvaluator.new(board.id)
    evaluator.process

    assert board.reload.failed?
    assert board.iterations.last.is_final
  end

  def test_stabilized_process
    board = Board.create!(height: 10, width: 10, max_iterations: 1000, life_locations: [ "(0, 0)", "(0, 1)", "(1, 0)", "(1, 1)", "(0, 2)" ])

    evaluator = BoardEvaluator.new(board.id)
    evaluator.process

    assert board.reload.stabilized?
    assert_equal 4, board.iterations.count
    assert board.iterations.last.is_final
  end
end
