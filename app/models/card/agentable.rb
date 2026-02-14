module Card::Agentable
  extend ActiveSupport::Concern

  included do
    has_many :agent_sessions, dependent: :destroy
  end
end
