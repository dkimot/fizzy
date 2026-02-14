class Chat::Message < ApplicationRecord
  self.table_name = "chat_messages"

  include Streamable

  belongs_to :account, default: -> { chat.account }
  belongs_to :chat, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  enum :role, %w[ user assistant ].index_by(&:itself)

  broadcasts_refreshes_to :chat

  scope :chronologically, -> { order(created_at: :asc) }

  delegate :card, to: :chat
end
