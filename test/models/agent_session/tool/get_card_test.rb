require "test_helper"

class AgentSession::Tool::GetCardTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @tool = AgentSession::Tool::GetCard.new(cards(:logo))
  end

  test "returns card details by number" do
    result = @tool.call("1")

    assert_includes result, "The logo isn't big enough"
  end

  test "returns error for missing card" do
    result = @tool.call("99999")

    assert_includes result, "Error: Card #99999 not found"
  end

  test "tool_name" do
    assert_equal "get_card", AgentSession::Tool::GetCard.tool_name
  end

  test "description" do
    assert AgentSession::Tool::GetCard.description.present?
  end
end
