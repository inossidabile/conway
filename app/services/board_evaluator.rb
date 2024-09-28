class BoardEvaluator
  class Cell
    NEIGHBOR_OFFSETS = (-1..1).to_a.repeated_permutation(2).to_a

    attr_reader :board, :x, :y, :alive, :neighbors_locations

    def self.within_board?(board, x, y)
      x >= 0 && x < board.width && y >= 0 && y < board.height
    end

    def initialize(board, x, y, alive)
      @board, @x, @y, @alive = board, x, y, alive
      @neighbors_locations = NEIGHBOR_OFFSETS
        .map { |ox, oy| [ x + ox, y + oy ] }
        .select { |nx, ny| Cell.within_board?(board, nx, ny) }
        .select { |nx, ny| nx != x || ny != y }
    end

    def find_neighbors(locations_map)
      @neighbors ||= neighbors_locations.map do |nx, ny|
        locations_map.at(nx, ny)
      end
    end

    def alive?
      alive
    end

    def dead?
      !alive
    end

    def to_point
      ActiveRecord::Point.new(x.to_f, y.to_f)
    end
  end

  class LocationsMap
    include Enumerable

    attr_reader :board, :iteration, :life_locations_set

    def initialize(board, iteration)
      @board = board
      @iteration = iteration
      @life_locations_set = iteration.life_locations.map { |l| build_key(l.x, l.y) }.to_set
      @map = {}
    end

    def build_key(x, y)
      "#{x.to_i}/#{y.to_i}"
    end

    def at(x, y)
      key = build_key(x, y)
      @map[key] ||= Cell.new(@board, x, y, life_locations_set.include?(key))
    end

    def each
      Board.each_location(board.width, board.height).each do |x, y|
        yield at(x, y)
      end
    end
  end

  class Context
    def initialize(board)
      @board = board
      @known_states = @board.iterations.pluck(:life_locations, :id).to_h.transform_keys { |x| x.hash }
      @iteration = @board.iterations.last
    end

    def failed?
      @known_states.count > @board.max_iterations
    end

    def stabilized?
      @iteration.original_iteration.present?
    end

    def alive_in_next_iteration?(cell, locations_map)
      neighbors = cell.find_neighbors(locations_map)

      return true if cell.alive? && (2..3).include?(neighbors.select(&:alive?).count)
      return true if cell.dead? && neighbors.select(&:alive?).count == 3
      false
    end

    def evolve!
      locations_map = LocationsMap.new(@board, @iteration)
      life_locations = locations_map
        .select { |cell| alive_in_next_iteration?(cell, locations_map) }
        .map(&:to_point)

      @iteration = @board.iterations.create!(
        life_locations: life_locations,
        original_iteration_id: @known_states[life_locations.hash]
      )

      @known_states[life_locations.hash] = @iteration.id
      @iteration.update!(is_final: true) if failed? || stabilized?
      @iteration
    end
  end

  def initialize(board_id)
    @board = Board.find(board_id)
    @board.evaluate! if @board.may_evaluate?

    @context = Context.new(@board)
  end

  def self.schedule(board)
    EvaluateBoardJob.perform_async(board.id)
    board
  end

  def tick!
    return true unless @board.evaluating?
    return @board.fail! if @context.failed?
    return @board.stabilize! if @context.stabilized?

    @context.evolve!
    false
  end

  def process
    until tick!; end
  end
end
