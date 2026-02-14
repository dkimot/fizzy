class Chat < ApplicationRecord
  include Messageable

  belongs_to :account, default: -> { card.account }
  belongs_to :card, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  has_many :turns, -> { order(created_at: :asc) }, as: :parent, dependent: :destroy

  broadcasts_refreshes

  scope :chronologically, -> { order(created_at: :asc) }

  delegate :board, to: :card
end
