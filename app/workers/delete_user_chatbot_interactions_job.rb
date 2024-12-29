class DeleteUserChatbotInteractionsJob
    include Sidekiq::Worker

    def perform
        UserChatbotInteraction.where('updated_at <= ?', 5.minutes.ago).find_each do |interaction|
            WhatsappMessageService.send_text_message(interaction.mobile_number,"You have been inactive for more than 5 minutes, this conversation is closed, please start over");
            interaction.destroy
        end
    end
end