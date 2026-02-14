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

  test "has turns in chronological order" do
    chat = chats(:logo_chat)

    assert_equal 2, chat.turns.count
    assert_equal "user", chat.turns.first.role
    assert_equal "assistant", chat.turns.last.role
  end

  test "reply creates user and assistant turns" do
    chat = chats(:logo_chat)

    assert_difference "Turn.count", 2 do
      user_turn, assistant_turn = chat.reply("Tell me about this card")

      assert_equal "user", user_turn.role
      assert_equal "Tell me about this card", user_turn.content
      assert_equal users(:david), user_turn.creator

      assert_equal "assistant", assistant_turn.role
      assert_equal "", assistant_turn.content
      assert assistant_turn.streaming?
      assert_equal users(:system), assistant_turn.creator
    end
  end

  test "reply enqueues stream job for assistant turn" do
    chat = chats(:logo_chat)

    assert_enqueued_with(job: Turn::StreamJob) do
      chat.reply("Tell me more")
    end
  end
end
