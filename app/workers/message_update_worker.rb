class MessageUpdateWorker
  include Sidekiq::Worker

  def perform(message_id, updates)
    ActiveRecord::Base.connection_pool.with_connection do
      # Directly fetch the message by ID
      message = Message.find_by(id: message_id)

      if message
        # Attempt to update the message
        if message.update(updates)
          Rails.logger.info("Message with ID #{message_id} updated successfully.")
        else
          Rails.logger.error("Failed to update message with ID #{message_id}: #{message.errors.full_messages.join(", ")}")
        end
      else
        Rails.logger.error("Message with ID #{message_id} not found for update.")
      end
    end
  end
end
