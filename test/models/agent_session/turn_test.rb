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

  test "enqueues process job via process_later" do
    turn = agent_session_turns(:logo_session_turn_one)

    assert_enqueued_with(job: AgentSession::Turn::ProcessJob) do
      turn.process_later
    end
  end

  test "chronologically scope orders by position" do
    session = agent_sessions(:logo_session)
    turns = session.turns.chronologically

    assert_equal turns, turns.sort_by(&:position)
  end

  test "continue_or_finish completes session when no tool call" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(tool_name: nil, response: "Final answer")
    turn.agent_session.update!(status: :processing)

    turn.send(:continue_or_finish)

    assert_equal "completed", turn.agent_session.reload.status
    assert_equal "Final answer", turn.agent_session.result
  end

  test "continue_or_finish takes next turn when tool call present" do
    turn = agent_session_turns(:logo_session_turn_one)
    turn.update!(tool_name: "search_cards", response: "need more info")
    turn.agent_session.update!(status: :processing)

    assert_enqueued_with(job: AgentSession::Turn::ProcessJob) do
      turn.send(:continue_or_finish)
    end
  end
end
