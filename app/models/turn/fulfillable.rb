module Turn::Fulfillable
  extend ActiveSupport::Concern

  def submit_later
    Turn::SubmitJob.perform_later(self)
  end

  def submit_now
    processing!
  rescue => e
    failed!
    parent.send(:mark_as_failed) if parent.respond_to?(:mark_as_failed, true)
    raise e
  end

  # Called when the LLM provider delivers a response, either via
  # a webhook callback or inline during submit. Records the response,
  # executes any tool call, and continues the agent loop.
  def fulfill(response_text:, tool_name: nil, tool_input: nil)
    update!(content: response_text, tool_name: tool_name, tool_input: tool_input)
    run_tool if tool_name.present?
    completed!
    continue_or_finish
  rescue => e
    failed!
    parent.send(:mark_as_failed) if parent.respond_to?(:mark_as_failed, true)
    raise e
  end

  private
    def run_tool
      output = toolbox.call(tool_name, tool_input)
      update!(tool_output: output)
    end

    def toolbox
      Chat::Toolbox.new(card)
    end

    def continue_or_finish
      if tool_name.present?
        parent.take_next_turn
      else
        parent.complete(result: content)
      end
    end
end
