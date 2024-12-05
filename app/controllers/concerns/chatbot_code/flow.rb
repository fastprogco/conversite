module Chatbot
  module Flow
    extend ActiveSupport::Concern

    def start(to_phone_number, params)
      puts "starting flow"
    end
  end
end
