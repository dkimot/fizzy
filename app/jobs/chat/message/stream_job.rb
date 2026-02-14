class Chat::Message::StreamJob < ApplicationJob
  queue_as :backend

  discard_on ActiveJob::DeserializationError

  def perform(message)
    message.stream_now
  end
end
