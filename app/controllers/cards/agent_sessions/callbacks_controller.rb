class Cards::AgentSessions::CallbacksController < ApplicationController
  include CardScoped

  before_action :set_agent_session
  before_action :set_turn

  def create
    @turn.fulfill(
      response_text: callback_params[:response],
      tool_name: callback_params[:tool_name],
      tool_input: callback_params[:tool_input]
    )

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    def set_agent_session
      @agent_session = @card.agent_sessions.find(params[:agent_session_id])
    end

    def set_turn
      @turn = @agent_session.turns.processing.find(params[:turn_id])
    end

    def callback_params
      params.expect(callback: [ :response, :tool_name, :tool_input ])
    end
end
