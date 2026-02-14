require "test_helper"

class ArtifactTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "belongs to account" do
    artifact = artifacts(:logo_plan)

    assert_equal accounts("37s"), artifact.account
  end

  test "validates name presence" do
    artifact = Artifact.new(account: accounts("37s"))
    assert_not artifact.valid?
    assert_includes artifact.errors[:name], "can't be blank"
  end

  test "has content attachment" do
    artifact = artifacts(:logo_plan)
    artifact.content.attach(
      io: StringIO.new("# Logo Redesign Plan"),
      filename: "plan.md",
      content_type: "text/plain"
    )

    assert artifact.content.attached?
    assert_equal "# Logo Redesign Plan", artifact.content.download
  end

  test "turns are nullified on destroy" do
    artifact = artifacts(:logo_plan)
    turn = turns(:logo_chat_assistant_turn)
    turn.update!(artifact: artifact)

    artifact.destroy!

    assert_nil turn.reload.artifact_id
  end
end
