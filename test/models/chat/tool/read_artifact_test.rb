require "test_helper"

class Chat::Tool::ReadArtifactTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @tool = Chat::Tool::ReadArtifact.new(cards(:logo))
    @artifact = artifacts(:logo_plan)
    @artifact.content.attach(
      io: StringIO.new("# Logo Plan Content"),
      filename: "plan.md",
      content_type: "text/plain"
    )
  end

  test "reads artifact content by id" do
    result = @tool.call(@artifact.id)

    assert_equal "# Logo Plan Content", result
  end

  test "returns error for missing artifact" do
    result = @tool.call("nonexistent-id")

    assert_includes result, "Error: Artifact not found"
  end

  test "returns error when artifact has no content" do
    @artifact.content.purge
    result = @tool.call(@artifact.id)

    assert_includes result, "Error: Artifact"
    assert_includes result, "has no content attached"
  end

  test "tool_name" do
    assert_equal "read_artifact", Chat::Tool::ReadArtifact.tool_name
  end
end
