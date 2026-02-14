class Turn::StreamJob < ApplicationJob
  queue_as :backend

  discard_on ActiveJob::DeserializationError

  def perform(turn)
    turn.stream_now
  end
end
