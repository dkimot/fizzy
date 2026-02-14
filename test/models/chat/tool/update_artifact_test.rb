require "test_helper"

class Chat::Tool::UpdateArtifactTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @tool = Chat::Tool::UpdateArtifact.new(cards(:logo))
    @artifact = artifacts(:logo_plan)
    @artifact.content.attach(
      io: StringIO.new("old content"),
      filename: "plan.md",
      content_type: "text/plain"
    )
  end

  test "updates artifact content" do
    input = { id: @artifact.id, content: "new content" }.to_json

    result = @tool.call(input)

    assert_includes result, "Artifact '#{@artifact.name}' updated"
    assert_equal "new content", @artifact.content.download
  end

  test "returns error for missing artifact" do
    input = { id: "nonexistent", content: "data" }.to_json

    result = @tool.call(input)

    assert_includes result, "Error: Artifact not found"
  end

  test "returns error for invalid JSON" do
    result = @tool.call("not json")

    assert_includes result, "Error: Input must be valid JSON"
  end

  test "tool_name" do
    assert_equal "update_artifact", Chat::Tool::UpdateArtifact.tool_name
  end
end
