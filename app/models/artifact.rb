class Artifact < ApplicationRecord
  belongs_to :account

  has_one_attached :content

  has_many :turns, dependent: :nullify

  validates :name, presence: true

  scope :chronologically, -> { order(created_at: :asc) }
end
