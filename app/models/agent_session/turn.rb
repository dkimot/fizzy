class AgentSession::Turn < ApplicationRecord
  self.table_name = "agent_session_turns"

  belongs_to :account, default: -> { agent_session.account }
  belongs_to :agent_session, touch: true

  enum :status, %w[ pending processing completed failed ].index_by(&:itself), default: :pending

  scope :chronologically, -> { order(position: :asc) }

  def submit_later
    AgentSession::Turn::SubmitJob.perform_later(self)
  end

  # Sends the LLM request and returns immediately.
  # The job worker is only occupied for the HTTP round-trip,
  # not waiting for the full LLM response. The provider calls
  # back to fulfill the turn when the response is ready.
  def submit_now
    processing!
  rescue => e
    failed!
    agent_session.send(:mark_as_failed)
    raise e
  end

  # Called when the LLM provider delivers a response, either via
  # a webhook callback or inline during submit. Records the response,
  # executes any tool call, and continues the agent loop.
  def fulfill(response_text:, tool_name: nil, tool_input: nil)
    update!(response: response_text, tool_name: tool_name, tool_input: tool_input)
    run_tool if tool_name.present?
    completed!
    continue_or_finish
  rescue => e
    failed!
    agent_session.send(:mark_as_failed)
    raise e
  end

  private
    def run_tool
      output = toolbox.call(tool_name, tool_input)
      update!(tool_output: output)
    end

    def toolbox
      AgentSession::Toolbox.new(agent_session.card)
    end

    def continue_or_finish
      if tool_name.present?
        agent_session.take_next_turn
      else
        agent_session.complete(result: response)
      end
    end
end
