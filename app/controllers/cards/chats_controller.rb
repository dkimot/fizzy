class Cards::ChatsController < ApplicationController
  include CardScoped

  before_action :set_chat, only: :show

  def create
    @chat = @card.chats.create!(creator: Current.user)

    respond_to do |format|
      format.turbo_stream
      format.json { head :created, location: card_chat_path(@card, @chat, format: :json) }
    end
  end

  def show
    respond_to do |format|
      format.turbo_stream
      format.json { render json: @chat.as_json(include: :turns) }
    end
  end

  private
    def set_chat
      @chat = @card.chats.find(params[:id])
    end
end
