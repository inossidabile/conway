
class IterationsController < ApplicationController
  class Cursor < Struct.new(:uuid, :offset)
    def self.from_params(params)
      new(params[:uuid] || SecureRandom.uuid, params[:offset].to_i || 0)
    end

    def advance(steps = 1)
      self.class.new(uuid, offset + steps)
    end
  end

  def index
    raise ActionController::BadRequest("Count parameter missing") if (count = params[:count].to_i).blank?

    iterations = Iteration
      .where(board_id: iteration_params[:board_id])
      .offset(cursor.offset)
      .limit(count)

    render json: {
      iterations:,
      cursor: cursor.advance(iterations.reject(&:is_final).count)
    }
  end

  def next
    iterations = Iteration
      .where(board_id: iteration_params[:board_id])
      .offset(cursor.offset)
      .limit(1)

    render json: {
      iteration: iterations.first,
      cursor: cursor.advance(iterations.reject(&:is_final).count)
    }
  end

  private

  def iteration_params
    params.permit(:board_id, cursor: [ :uuid, :offset ]).tap do |p|
      p.require([ :board_id, :cursor ])
    end
  end

  def cursor
    Cursor.from_params(iteration_params[:cursor])
  end
end
