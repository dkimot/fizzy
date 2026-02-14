require "test_helper"

class Chat::MessageTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "belongs to chat and account" do
    message = chat_messages(:logo_chat_user_message)

    assert_equal chats(:logo_chat), message.chat
    assert_equal accounts("37s"), message.account
  end

  test "user and assistant roles" do
    assert chat_messages(:logo_chat_user_message).user?
    assert chat_messages(:logo_chat_assistant_message).assistant?
  end

  test "enqueues stream job via stream_later" do
    message = chat_messages(:logo_chat_assistant_message)

    assert_enqueued_with(job: Chat::Message::StreamJob) do
      message.stream_later
    end
  end

  test "stream_now sets streaming flag" do
    message = chat_messages(:logo_chat_assistant_message)
    message.update!(streaming: false)

    message.stream_now

    assert message.streaming?
  end

  test "append adds chunk to content" do
    message = chat_messages(:logo_chat_assistant_message)
    message.update!(content: "Hello", streaming: true)

    message.append(" world")

    assert_equal "Hello world", message.content
  end

  test "finish clears streaming flag" do
    message = chat_messages(:logo_chat_assistant_message)
    message.update!(streaming: true)

    message.finish

    assert_not message.streaming?
  end

  test "finish with tool call executes tool and continues" do
    message = chat_messages(:logo_chat_assistant_message)
    message.update!(streaming: true, content: "Let me look that up")

    assert_enqueued_with(job: Chat::Message::StreamJob) do
      message.finish(tool_name: "get_card", tool_input: "1")
    end

    assert_equal "get_card", message.tool_name
    assert_not_nil message.tool_output
    assert_not message.streaming?
  end

  test "finish with unknown tool records error" do
    message = chat_messages(:logo_chat_assistant_message)
    message.update!(streaming: true)

    message.finish(tool_name: "nonexistent", tool_input: "test")

    assert_includes message.tool_output, "Unknown tool"
  end

  test "chronologically scope orders by created_at" do
    chat = chats(:logo_chat)
    messages = chat.messages.chronologically

    assert_equal messages, messages.sort_by(&:created_at)
  end
end
