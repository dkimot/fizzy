class Cards::Chats::MessagesController < ApplicationController
  include CardScoped

  before_action :set_chat

  def create
    @user_message, @assistant_message = @chat.reply(message_params[:content])

    respond_to do |format|
      format.turbo_stream
      format.json { head :created }
    end
  end

  private
    def set_chat
      @chat = @card.chats.find(params[:chat_id])
    end

    def message_params
      params.expect(message: [ :content ])
    end
end
