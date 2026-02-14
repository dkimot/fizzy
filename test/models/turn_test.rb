require "test_helper"

class TurnTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "belongs to agent session via polymorphic parent" do
    turn = turns(:logo_session_turn_one)

    assert_equal agent_sessions(:logo_session), turn.parent
    assert_equal accounts("37s"), turn.account
  end

  test "belongs to chat via polymorphic parent" do
    turn = turns(:logo_chat_user_turn)

    assert_equal chats(:logo_chat), turn.parent
    assert_equal accounts("37s"), turn.account
  end

  test "enqueues submit job via submit_later" do
    turn = turns(:logo_session_turn_one)

    assert_enqueued_with(job: Turn::SubmitJob) do
      turn.submit_later
    end
  end

  test "submit_now transitions to processing" do
    turn = turns(:logo_session_turn_one)
    turn.update!(status: :pending)

    turn.submit_now

    assert_equal "processing", turn.status
  end

  test "fulfill records response and completes turn" do
    turn = turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.parent.update!(status: :processing)

    turn.fulfill(response_text: "Final answer")

    assert_equal "completed", turn.status
    assert_equal "Final answer", turn.content
    assert_equal "completed", turn.parent.reload.status
  end

  test "fulfill with tool call executes tool and continues" do
    turn = turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.parent.update!(status: :processing)

    assert_enqueued_with(job: Turn::SubmitJob) do
      turn.fulfill(response_text: "need more info", tool_name: "get_card", tool_input: "1")
    end

    assert_equal "completed", turn.status
    assert_equal "get_card", turn.tool_name
    assert_not_nil turn.tool_output
  end

  test "fulfill with unknown tool records error in tool_output" do
    turn = turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.parent.update!(status: :processing)

    turn.fulfill(response_text: "trying", tool_name: "nonexistent", tool_input: "test")

    assert_includes turn.tool_output, "Unknown tool"
  end

  test "enqueues stream job via stream_later" do
    turn = turns(:logo_chat_assistant_turn)

    assert_enqueued_with(job: Turn::StreamJob) do
      turn.stream_later
    end
  end

  test "stream_now sets streaming flag" do
    turn = turns(:logo_chat_assistant_turn)
    turn.update!(streaming: false)

    turn.stream_now

    assert turn.streaming?
  end

  test "append adds chunk to content" do
    turn = turns(:logo_chat_assistant_turn)
    turn.update!(content: "Hello", streaming: true)

    turn.append(" world")

    assert_equal "Hello world", turn.content
  end

  test "finish clears streaming flag" do
    turn = turns(:logo_chat_assistant_turn)
    turn.update!(streaming: true)

    turn.finish

    assert_not turn.streaming?
  end

  test "finish with tool call executes tool and continues" do
    turn = turns(:logo_chat_assistant_turn)
    turn.update!(streaming: true, content: "Let me look that up")

    assert_enqueued_with(job: Turn::StreamJob) do
      turn.finish(tool_name: "get_card", tool_input: "1")
    end

    assert_equal "get_card", turn.tool_name
    assert_not_nil turn.tool_output
    assert_not turn.streaming?
  end

  test "user and assistant roles" do
    assert turns(:logo_chat_user_turn).user?
    assert turns(:logo_chat_assistant_turn).assistant?
  end

  test "card delegates to parent" do
    turn = turns(:logo_session_turn_one)
    assert_equal cards(:logo), turn.card
  end

  test "can reference artifact" do
    turn = turns(:logo_chat_assistant_turn)
    artifact = artifacts(:logo_plan)
    turn.update!(artifact: artifact)

    assert_equal artifact, turn.reload.artifact
  end

  test "effective_content falls back to content when no artifact" do
    turn = turns(:logo_chat_user_turn)

    assert_equal turn.content, turn.effective_content
  end
end
