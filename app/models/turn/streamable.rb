module Turn::Streamable
  extend ActiveSupport::Concern

  def stream_later
    Turn::StreamJob.perform_later(self)
  end

  # Called by StreamJob. The actual LLM integration calls
  # append(chunk) for each response chunk and finish() when done.
  def stream_now
    update!(streaming: true)
  rescue => e
    update!(streaming: false)
    raise e
  end

  # Appends a chunk to the turn content and saves,
  # triggering broadcasts_refreshes to push the update via ActionCable.
  def append(chunk)
    update!(content: content + chunk)
  end

  # Called when the LLM response is complete. If a tool call
  # was requested, executes it and continues the conversation.
  def finish(tool_name: nil, tool_input: nil)
    if tool_name.present?
      execute_tool(tool_name, tool_input)
      parent.reply_from_tool(tool_output)
    end

    update!(streaming: false)
  end

  private
    def execute_tool(tool_name, tool_input)
      output = Chat::Toolbox.new(card).call(tool_name, tool_input)
      update!(tool_name: tool_name, tool_input: tool_input, tool_output: output)
    end
end
