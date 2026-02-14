class AgentSession::Tool::SearchCards < AgentSession::Tool
  def self.description
    "Search for cards in the current board by keyword. Input: a search query string."
  end

  def call(input)
    cards = board.cards.published.where("title LIKE ?", "%#{input}%").limit(10)
    cards.map(&:to_prompt).join("\n")
  end
end
