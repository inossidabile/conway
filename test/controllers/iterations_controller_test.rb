require "test_helper"

class IterationsControllerTest < ActionDispatch::IntegrationTest
  include AssertJson

  setup do
    Sidekiq::Testing.inline! do
      @board = BoardEvaluator.schedule(Board.create!(height: 10, width: 10, life_locations: [
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
      ]))
    end
  end

  test "should get index" do
    uuid = SecureRandom.uuid
    get iterations_url(board_id: @board.id, cursor: { uuid: }, count: 2)

    assert_response :success
    assert_json(@response.body) do
      has :cursor do
        has :uuid, uuid
        has :offset, 2
      end
      has :iterations do
        has_length_of 2
        item 0 do
          has :id
          has :board_id, @board.id
          has :life_locations
          has :is_final
        end
      end
    end
  end

  test "should get index with exceeding count" do
    uuid = SecureRandom.uuid
    iterations_count = @board.iterations.count
    get iterations_url(board_id: @board.id, cursor: { uuid: }, count: 100)

    assert_response :success
    assert_json(@response.body) do
      has :cursor do
        has :uuid, uuid
        has :offset, iterations_count - 1
      end
      has :iterations do
        has_length_of iterations_count
        item 0 do
          has :id
          has :board_id, @board.id
          has :life_locations
          has :is_final
        end
      end
    end

    get next_iterations_url(board_id: @board.id, cursor: { uuid:, offset: iterations_count - 1 })
    assert_response :success
    assert_json(@response.body) do
      has :cursor do
        has :uuid, uuid
        has :offset, iterations_count - 1
      end
      has :iteration do
        has :id
        has :board_id, @board.id
        has :life_locations
        has :is_final
      end
    end
  end

  test "should get show" do
    uuid = SecureRandom.uuid
    get next_iterations_url(board_id: @board.id, cursor: { uuid: })

    assert_response :success
    assert_json(@response.body) do
      has :cursor do
        has :uuid, uuid
        has :offset, 1
      end
      has :iteration do
        has :id
        has :board_id, @board.id
        has :life_locations
        has :is_final
      end
    end
  end
end
