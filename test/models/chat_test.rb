require "test_helper"

class ChatTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "belongs to card and account" do
    chat = chats(:logo_chat)

    assert_equal cards(:logo), chat.card
    assert_equal accounts("37s"), chat.account
    assert_equal users(:david), chat.creator
  end

  test "card has many chats" do
    assert_includes cards(:logo).chats, chats(:logo_chat)
  end

  test "has messages in chronological order" do
    chat = chats(:logo_chat)

    assert_equal 2, chat.messages.count
    assert_equal "user", chat.messages.first.role
    assert_equal "assistant", chat.messages.last.role
  end

  test "reply creates user and assistant messages" do
    chat = chats(:logo_chat)

    assert_difference "Chat::Message.count", 2 do
      user_msg, assistant_msg = chat.reply("Tell me about this card")

      assert_equal "user", user_msg.role
      assert_equal "Tell me about this card", user_msg.content
      assert_equal users(:david), user_msg.creator

      assert_equal "assistant", assistant_msg.role
      assert_equal "", assistant_msg.content
      assert assistant_msg.streaming?
      assert_equal users(:system), assistant_msg.creator
    end
  end

  test "reply enqueues stream job for assistant message" do
    chat = chats(:logo_chat)

    assert_enqueued_with(job: Chat::Message::StreamJob) do
      chat.reply("Tell me more")
    end
  end
end
