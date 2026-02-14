class AgentSession::Tool::GetCard < AgentSession::Tool
  def self.description
    "Get the full details of a card by its number. Input: the card number."
  end

  def call(input)
    if found_card = account.cards.published.find_by(number: input.to_i)
      found_card.to_prompt
    else
      { error: "Card ##{input} not found" }.to_json
    end
  end
end
