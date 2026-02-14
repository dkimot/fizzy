module Card::Chattable
  extend ActiveSupport::Concern

  included do
    has_many :chats, dependent: :destroy
  end
end
