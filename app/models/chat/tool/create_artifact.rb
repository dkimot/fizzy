class Chat::Tool::CreateArtifact < Chat::Tool
  def self.description
    "Create a new artifact to store content. Input: JSON with 'name' and 'content' keys."
  end

  def call(input)
    params = JSON.parse(input)
    artifact = account.artifacts.create!(
      name: params.fetch("name"),
      mime_type: params.fetch("mime_type", "text/plain")
    )
    artifact.content.attach(
      io: StringIO.new(params.fetch("content")),
      filename: artifact.name,
      content_type: artifact.mime_type
    )

    "Artifact '#{artifact.name}' created with id: #{artifact.id}"
  rescue JSON::ParserError
    "Error: Input must be valid JSON with 'name' and 'content' keys"
  rescue KeyError => e
    "Error: Missing required key: #{e.message}"
  end
end
