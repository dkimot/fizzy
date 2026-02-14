class Chat::Tool::ReadArtifact < Chat::Tool
  def self.description
    "Read the content of an artifact by its id. Input: the artifact id."
  end

  def call(input)
    if artifact = account.artifacts.find_by(id: input.strip)
      if artifact.content.attached?
        artifact.content.download
      else
        "Error: Artifact '#{artifact.name}' has no content attached"
      end
    else
      "Error: Artifact not found with id: #{input}"
    end
  end
end
