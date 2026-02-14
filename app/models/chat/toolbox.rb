class Chat::Toolbox
  attr_reader :card

  TOOLS = [
    Chat::Tool::SearchCards,
    Chat::Tool::GetCard
  ]

  def initialize(card)
    @card = card
  end

  def call(tool_name, input)
    if tool_class = find(tool_name)
      tool_class.new(card).call(input)
    else
      "Error: Unknown tool: #{tool_name}"
    end
  end

  def definitions
    TOOLS.map do |tool_class|
      { name: tool_class.tool_name, description: tool_class.description }
    end
  end

  private
    def find(tool_name)
      TOOLS.find { |tool_class| tool_class.tool_name == tool_name }
    end
end
