module Chat::Messageable
  extend ActiveSupport::Concern

  def reply(content)
    user_turn = turns.create!(
      role: :user,
      content: content,
      creator: Current.user
    )

    assistant_turn = create_assistant_turn

    [ user_turn, assistant_turn ]
  end

  def reply_from_tool(tool_output)
    create_assistant_turn
  end

  private
    def create_assistant_turn
      turns.create!(
        role: :assistant,
        content: "",
        creator: account.system_user,
        streaming: true
      ).tap(&:stream_later)
    end
end
