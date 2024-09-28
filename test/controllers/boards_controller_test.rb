require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  include AssertJson

  test "should create board" do
    assert_difference -> { Board.count } => 1, -> { Iteration.count } => 3 do
      Sidekiq::Testing.inline! do
        post boards_url, params: { board: { height: 10, width: 10, life_locations: [ "(0, 1)", "(1, 1)" ] } }
      end
    end

    assert_response :success
    assert_json(@response.body) do
      has :board do
        has :id
        has :height, 10
        has :width, 10
        has :life_locations, [ { "x" => 0, "y" => 1 }, { "x" => 1, "y" => 1 } ]
        has :max_iterations, 100
        has :status, "initialized"
      end
    end
  end

  test "should show board" do
    board = Board.create!(height: 10, width: 10, life_locations: [
      "(0.0, 1.0)",
      "(0.0, 4.0)",
      "(0.0, 5.0)",
      "(0.0, 7.0)",
      "(0.0, 9.0)",
      "(1.0, 0.0)",
      "(1.0, 6.0)",
      "(1.0, 7.0)",
      "(1.0, 9.0)",
      "(2.0, 1.0)",
      "(2.0, 2.0)",
      "(2.0, 3.0)",
      "(2.0, 4.0)",
      "(2.0, 7.0)",
      "(2.0, 8.0)",
      "(3.0, 0.0)",
      "(3.0, 1.0)",
      "(3.0, 2.0)",
      "(3.0, 3.0)",
      "(3.0, 4.0)",
      "(3.0, 5.0)",
      "(3.0, 6.0)",
      "(4.0, 0.0)",
      "(4.0, 1.0)",
      "(4.0, 3.0)",
      "(4.0, 4.0)",
      "(4.0, 5.0)",
      "(4.0, 6.0)",
      "(4.0, 8.0)",
      "(5.0, 0.0)",
      "(5.0, 1.0)",
      "(5.0, 5.0)",
      "(5.0, 6.0)",
      "(6.0, 0.0)",
      "(6.0, 1.0)",
      "(6.0, 6.0)",
      "(6.0, 7.0)",
      "(6.0, 8.0)",
      "(6.0, 9.0)",
      "(7.0, 0.0)",
      "(7.0, 2.0)",
      "(7.0, 4.0)",
      "(7.0, 5.0)",
      "(8.0, 2.0)",
      "(8.0, 3.0)",
      "(8.0, 8.0)",
      "(9.0, 0.0)",
      "(9.0, 2.0)",
      "(9.0, 4.0)",
      "(9.0, 7.0)",
      "(9.0, 8.0)",
      "(9.0, 9.0)"
    ])
    Sidekiq::Testing.inline! do
      BoardEvaluator.schedule(board)
    end

    get board_url(board.id)

    assert_response :success
    assert_json(@response.body) do
      has :board do
        has :id, board.id
        has :height, 10
        has :width, 10
        has :life_locations, [ { "x"=>0.0, "y"=>1.0 }, { "x"=>0.0, "y"=>4.0 }, { "x"=>0.0, "y"=>5.0 }, { "x"=>0.0, "y"=>7.0 }, { "x"=>0.0, "y"=>9.0 }, { "x"=>1.0, "y"=>0.0 }, { "x"=>1.0, "y"=>6.0 }, { "x"=>1.0, "y"=>7.0 }, { "x"=>1.0, "y"=>9.0 }, { "x"=>2.0, "y"=>1.0 }, { "x"=>2.0, "y"=>2.0 }, { "x"=>2.0, "y"=>3.0 }, { "x"=>2.0, "y"=>4.0 }, { "x"=>2.0, "y"=>7.0 }, { "x"=>2.0, "y"=>8.0 }, { "x"=>3.0, "y"=>0.0 }, { "x"=>3.0, "y"=>1.0 }, { "x"=>3.0, "y"=>2.0 }, { "x"=>3.0, "y"=>3.0 }, { "x"=>3.0, "y"=>4.0 }, { "x"=>3.0, "y"=>5.0 }, { "x"=>3.0, "y"=>6.0 }, { "x"=>4.0, "y"=>0.0 }, { "x"=>4.0, "y"=>1.0 }, { "x"=>4.0, "y"=>3.0 }, { "x"=>4.0, "y"=>4.0 }, { "x"=>4.0, "y"=>5.0 }, { "x"=>4.0, "y"=>6.0 }, { "x"=>4.0, "y"=>8.0 }, { "x"=>5.0, "y"=>0.0 }, { "x"=>5.0, "y"=>1.0 }, { "x"=>5.0, "y"=>5.0 }, { "x"=>5.0, "y"=>6.0 }, { "x"=>6.0, "y"=>0.0 }, { "x"=>6.0, "y"=>1.0 }, { "x"=>6.0, "y"=>6.0 }, { "x"=>6.0, "y"=>7.0 }, { "x"=>6.0, "y"=>8.0 }, { "x"=>6.0, "y"=>9.0 }, { "x"=>7.0, "y"=>0.0 }, { "x"=>7.0, "y"=>2.0 }, { "x"=>7.0, "y"=>4.0 }, { "x"=>7.0, "y"=>5.0 }, { "x"=>8.0, "y"=>2.0 }, { "x"=>8.0, "y"=>3.0 }, { "x"=>8.0, "y"=>8.0 }, { "x"=>9.0, "y"=>0.0 }, { "x"=>9.0, "y"=>2.0 }, { "x"=>9.0, "y"=>4.0 }, { "x"=>9.0, "y"=>7.0 }, { "x"=>9.0, "y"=>8.0 }, { "x"=>9.0, "y"=>9.0 } ]
        has :max_iterations, 100
        has :status, "stabilized"
        has :last_iteration do
          has :life_locations, [ { "x"=>7.0, "y"=>4.0 }, { "x"=>7.0, "y"=>5.0 }, { "x"=>8.0, "y"=>4.0 }, { "x"=>8.0, "y"=>5.0 } ]
        end
      end
    end
  end
end
