require "test_helper"

class AgentSessionTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "creates with pending status by default" do
    session = cards(:logo).agent_sessions.create!(prompt: "Summarize this card")

    assert_equal "pending", session.status
    assert_equal cards(:logo), session.card
    assert_equal users(:david), session.creator
    assert_equal accounts("37s"), session.account
  end

  test "enqueues run job on create" do
    assert_enqueued_with(job: AgentSession::RunJob) do
      cards(:logo).agent_sessions.create!(prompt: "Summarize this card")
    end
  end

  test "run_now transitions to processing" do
    session = agent_sessions(:logo_session)
    session.update!(status: :pending)

    # Stub take_next_turn to avoid hitting the submit job chain
    session.stub(:take_next_turn, nil) do
      session.run_now
    end

    assert_equal "processing", session.status
  end

  test "complete marks session as completed with result" do
    session = agent_sessions(:logo_session)
    session.update!(status: :processing)

    freeze_time do
      session.complete(result: "Here is the summary")

      assert_equal "completed", session.status
      assert_equal "Here is the summary", session.result
      assert_equal Time.current, session.completed_at
    end
  end

  test "turns_remaining? respects max turns" do
    session = agent_sessions(:logo_session)

    assert session.turns_remaining?
  end

  test "card has many agent sessions" do
    assert_includes cards(:logo).agent_sessions, agent_sessions(:logo_session)
  end

  test "validates prompt presence" do
    session = AgentSession.new(card: cards(:logo), creator: users(:david))
    assert_not session.valid?
    assert_includes session.errors[:prompt], "can't be blank"
  end

  test "turns are polymorphically associated" do
    session = agent_sessions(:logo_session)
    turn = turns(:logo_session_turn_one)

    assert_includes session.turns, turn
    assert_equal session, turn.parent
  end
end
