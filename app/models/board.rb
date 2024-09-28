class Board < ApplicationRecord
  include AASM

  has_many :iterations
  has_one :last_iteration, -> { order(id: :desc) }, class_name: "Iteration"

  validates :height, presence: true
  validates :width, presence: true
  validates :life_locations, presence: true

  aasm column: "status" do # default column: aasm_state
    state :initialized, initial: true
    state :evaluating
    state :failed
    state :stabilized

    event :evaluate do
      after do
        self.iterations.create!(life_locations:)
      end
      transitions from: :initialized, to: :evaluating
    end

    event :fail do
      transitions from: :evaluating, to: :failed
    end

    event :stabilize do
      transitions from: :evaluating, to: :stabilized
    end
  end

  def self.each_location(width, height)
    Enumerator.new do |yielder|
      width.times do |x|
        height.times do |y|
          yielder.yield(x, y)
        end
      end
    end
  end
end
