class Cards::AgentSessionsController < ApplicationController
  include CardScoped

  before_action :set_agent_session, only: :show

  def create
    @agent_session = @card.agent_sessions.create!(agent_session_params)

    respond_to do |format|
      format.turbo_stream
      format.json { head :created, location: card_agent_session_path(@card, @agent_session, format: :json) }
    end
  end

  def show
    respond_to do |format|
      format.turbo_stream
      format.json { render json: @agent_session.as_json(include: :turns) }
    end
  end

  private
    def set_agent_session
      @agent_session = @card.agent_sessions.find(params[:id])
    end

    def agent_session_params
      params.expect(agent_session: [ :prompt ])
    end
end
