module AgentSession::Turnable
  extend ActiveSupport::Concern

  MAX_TURNS = 10

  def take_next_turn
    if turns_remaining?
      turns.create!(position: next_position).process_later
    else
      complete(result: turns.last&.response)
    end
  end

  def turns_remaining?
    turns.count < MAX_TURNS
  end

  private
    def next_position
      (turns.maximum(:position) || 0) + 1
    end
end
