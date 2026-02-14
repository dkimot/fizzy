class AgentSession < ApplicationRecord
  include Eventable, Runnable, Turnable

  belongs_to :account, default: -> { card.account }
  belongs_to :card, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  has_many :turns, -> { order(position: :asc) }, class_name: "AgentSession::Turn", dependent: :destroy

  enum :status, %w[ pending processing completed failed ].index_by(&:itself), default: :pending

  validates :prompt, presence: true

  scope :chronologically, -> { order(created_at: :asc) }

  delegate :board, to: :card
end
