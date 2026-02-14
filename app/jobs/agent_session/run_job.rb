class AgentSession::RunJob < ApplicationJob
  queue_as :backend

  discard_on ActiveJob::DeserializationError

  def perform(agent_session)
    agent_session.run_now
  end
end
