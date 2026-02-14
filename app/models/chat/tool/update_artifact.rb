class Chat::Tool::UpdateArtifact < Chat::Tool
  def self.description
    "Update an artifact's content. Input: JSON with 'id' and 'content' keys."
  end

  def call(input)
    params = JSON.parse(input)
    artifact_id = params.fetch("id")

    if artifact = account.artifacts.find_by(id: artifact_id)
      artifact.content.attach(
        io: StringIO.new(params.fetch("content")),
        filename: artifact.name,
        content_type: artifact.mime_type
      )

      "Artifact '#{artifact.name}' updated"
    else
      "Error: Artifact not found with id: #{artifact_id}"
    end
  rescue JSON::ParserError
    "Error: Input must be valid JSON with 'id' and 'content' keys"
  rescue KeyError => e
    "Error: Missing required key: #{e.message}"
  end
end
