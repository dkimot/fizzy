class Turn::SubmitJob < ApplicationJob
  queue_as :backend

  discard_on ActiveJob::DeserializationError

  def perform(turn)
    turn.submit_now
  end
end
