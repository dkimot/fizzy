require "test_helper"

class Chat::Tool::CreateArtifactTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @tool = Chat::Tool::CreateArtifact.new(cards(:logo))
  end

  test "creates artifact with content" do
    input = { name: "plan.md", content: "# My Plan" }.to_json

    result = @tool.call(input)

    assert_includes result, "Artifact 'plan.md' created"
    artifact = accounts("37s").artifacts.find_by(name: "plan.md")
    assert artifact.present?
    assert_equal "# My Plan", artifact.content.download
  end

  test "creates artifact with custom mime type" do
    input = { name: "data.json", content: '{"key": "value"}', mime_type: "application/json" }.to_json

    result = @tool.call(input)

    artifact = accounts("37s").artifacts.find_by(name: "data.json")
    assert_equal "application/json", artifact.mime_type
  end

  test "returns error for invalid JSON" do
    result = @tool.call("not json")

    assert_includes result, "Error: Input must be valid JSON"
  end

  test "returns error for missing required keys" do
    result = @tool.call({ name: "test" }.to_json)

    assert_includes result, "Error: Missing required key"
  end

  test "tool_name" do
    assert_equal "create_artifact", Chat::Tool::CreateArtifact.tool_name
  end
end
