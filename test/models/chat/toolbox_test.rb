require "test_helper"

class Chat::ToolboxTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @toolbox = Chat::Toolbox.new(cards(:logo))
  end

  test "call dispatches to known tool" do
    result = @toolbox.call("get_card", "1")

    assert_includes result, "The logo isn't big enough"
  end

  test "call returns error for unknown tool" do
    result = @toolbox.call("nonexistent", "test")

    assert_includes result, "Unknown tool: nonexistent"
  end

  test "definitions lists all available tools" do
    definitions = @toolbox.definitions

    assert_equal 5, definitions.length
    assert_includes definitions.map { |d| d[:name] }, "search_cards"
    assert_includes definitions.map { |d| d[:name] }, "get_card"
    assert_includes definitions.map { |d| d[:name] }, "create_artifact"
    assert_includes definitions.map { |d| d[:name] }, "read_artifact"
    assert_includes definitions.map { |d| d[:name] }, "update_artifact"
    assert definitions.all? { |d| d[:description].present? }
  end
end
