class Cards::Chats::TurnsController < ApplicationController
  include CardScoped

  before_action :set_chat

  def create
    @user_turn, @assistant_turn = @chat.reply(turn_params[:content])

    respond_to do |format|
      format.turbo_stream
      format.json { head :created }
    end
  end

  private
    def set_chat
      @chat = @card.chats.find(params[:chat_id])
    end

    def turn_params
      params.expect(turn: [ :content ])
    end
end
