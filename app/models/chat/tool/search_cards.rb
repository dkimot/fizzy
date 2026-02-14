class Chat::Tool::SearchCards < Chat::Tool
  def self.description
    "Search for cards in the current board by keyword. Input: a search query string."
  end

  def call(input)
    cards = board.cards.published.where("title LIKE ?", "%#{sanitize(input)}%").limit(10)
    cards.map(&:to_prompt).join("\n")
  end

  private
    def sanitize(input)
      ActiveRecord::Base.sanitize_sql_like(input)
    end
end
