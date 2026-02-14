require "test_helper"

class AgentSession::TurnTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "belongs to agent session" do
    turn = agent_session_turns(:logo_session_turn_one)

    assert_equal agent_sessions(:logo_session), turn.agent_session
    assert_equal accounts("37s"), turn.account
  end

  test "enqueues submit job via submit_later" do
    turn = agent_session_turns(:logo_session_turn_one)

    assert_enqueued_with(job: AgentSession::Turn::SubmitJob) do
      turn.submit_later
    end
  end

  test "submit_now transitions to processing" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(status: :pending)

    turn.submit_now

    assert_equal "processing", turn.status
  end

  test "fulfill records response and completes turn" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.agent_session.update!(status: :processing)

    turn.fulfill(response_text: "Final answer")

    assert_equal "completed", turn.status
    assert_equal "Final answer", turn.response
    assert_equal "completed", turn.agent_session.reload.status
  end

  test "fulfill with tool call executes tool and continues" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.agent_session.update!(status: :processing)

    assert_enqueued_with(job: AgentSession::Turn::SubmitJob) do
      turn.fulfill(response_text: "need more info", tool_name: "get_card", tool_input: "1")
    end

    assert_equal "completed", turn.status
    assert_equal "get_card", turn.tool_name
    assert_not_nil turn.tool_output
  end

  test "fulfill with unknown tool records error in tool_output" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(status: :processing)
    turn.agent_session.update!(status: :processing)

    turn.fulfill(response_text: "trying", tool_name: "nonexistent", tool_input: "test")

    assert_includes turn.tool_output, "Unknown tool"
  end

  test "chronologically scope orders by position" do
    session = agent_sessions(:logo_session)
    turns = session.turns.chronologically

    assert_equal turns, turns.sort_by(&:position)
  end
end
