class AgentSession::Turn::ProcessJob < ApplicationJob
  queue_as :backend

  discard_on ActiveJob::DeserializationError

  def perform(turn)
    turn.process_now
  end
end
