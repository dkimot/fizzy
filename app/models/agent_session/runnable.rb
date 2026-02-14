module AgentSession::Runnable
  extend ActiveSupport::Concern

  included do
    after_create_commit :run_later
  end

  def run_later
    AgentSession::RunJob.perform_later(self)
  end

  def run_now
    processing!
    take_next_turn
  rescue => e
    mark_as_failed
    raise e
  end

  def complete(result:)
    update!(status: :completed, result: result, completed_at: Time.current)
    track_event :completed, creator: creator
  end

  private
    def mark_as_failed
      update!(status: :failed)
      track_event :failed, creator: creator
    end
end
