class Chat::Tool
  attr_reader :card

  def initialize(card)
    @card = card
  end

  def self.tool_name
    name.demodulize.underscore
  end

  def self.description
    raise NotImplementedError, "Subclasses must implement description"
  end

  def call(input)
    raise NotImplementedError, "Subclasses must implement call"
  end

  private
    delegate :account, :board, to: :card
end
