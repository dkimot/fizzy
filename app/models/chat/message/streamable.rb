module Chat::Message::Streamable
  extend ActiveSupport::Concern

  def stream_later
    Chat::Message::StreamJob.perform_later(self)
  end

  # Called by StreamJob. Subclasses or configurations provide the
  # actual LLM integration. The job appends chunks to content and
  # broadcasts_refreshes pushes updates to subscribers via ActionCable.
  def stream_now
    update!(streaming: true)
  rescue => e
    update!(streaming: false)
    raise e
  end

  # Called after each chunk arrives from the LLM provider.
  # Appends the chunk to the message content and saves,
  # triggering broadcasts_refreshes to push the update.
  def append(chunk)
    update!(content: content + chunk)
  end

  # Called when the LLM response is complete. If a tool call
  # was requested, executes it and continues the conversation.
  def finish(tool_name: nil, tool_input: nil)
    if tool_name.present?
      run_tool(tool_name, tool_input)
      chat.reply_from_tool(tool_output)
    end

    update!(streaming: false)
  end

  private
    def run_tool(tool_name, tool_input)
      output = Chat::Toolbox.new(card).call(tool_name, tool_input)
      update!(tool_name: tool_name, tool_input: tool_input, tool_output: output)
    end
end
