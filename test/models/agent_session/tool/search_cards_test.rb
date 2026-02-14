require "test_helper"

class AgentSession::Tool::SearchCardsTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @tool = AgentSession::Tool::SearchCards.new(cards(:logo))
  end

  test "finds cards matching query" do
    result = @tool.call("logo")

    assert_includes result, "The logo isn't big enough"
  end

  test "returns empty for no matches" do
    result = @tool.call("xyznonexistent")

    assert_equal "", result
  end

  test "tool_name" do
    assert_equal "search_cards", AgentSession::Tool::SearchCards.tool_name
  end

  test "description" do
    assert AgentSession::Tool::SearchCards.description.present?
  end
end
