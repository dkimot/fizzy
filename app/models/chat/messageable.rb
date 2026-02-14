module Chat::Messageable
  extend ActiveSupport::Concern

  def reply(content)
    user_message = messages.create!(
      role: :user,
      content: content,
      creator: Current.user
    )

    assistant_message = create_assistant_message

    [ user_message, assistant_message ]
  end

  def reply_from_tool(tool_output)
    create_assistant_message
  end

  private
    def create_assistant_message
      messages.create!(
        role: :assistant,
        content: "",
        creator: account.system_user,
        streaming: true
      ).tap(&:stream_later)
    end
end
