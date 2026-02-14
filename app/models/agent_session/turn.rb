class AgentSession::Turn < ApplicationRecord
  self.table_name = "agent_session_turns"

  belongs_to :account, default: -> { agent_session.account }
  belongs_to :agent_session, touch: true

  enum :status, %w[ pending processing completed failed ].index_by(&:itself), default: :pending

  scope :chronologically, -> { order(position: :asc) }

  def process_later
    AgentSession::Turn::ProcessJob.perform_later(self)
  end

  def process_now
    processing!
    execute
    completed!
    continue_or_finish
  rescue => e
    failed!
    agent_session.send(:mark_as_failed)
    raise e
  end

  private
    def execute
      # Subclass or configure with a strategy to call the LLM provider.
      # The response, tool_name, tool_input, and tool_output fields
      # capture the full turn lifecycle:
      #
      #   1. Send prompt + context → LLM
      #   2. Record response
      #   3. If tool_call requested → execute tool, record tool_output
      raise NotImplementedError, "Subclasses must implement execute"
    end

    def continue_or_finish
      if tool_name.present?
        agent_session.take_next_turn
      else
        agent_session.complete(result: response)
      end
    end
end
