class Iteration < ApplicationRecord
  belongs_to :board
  belongs_to :original_iteration, class_name: "Iteration", optional: true
end
