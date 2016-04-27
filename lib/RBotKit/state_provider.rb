module RBotKit
 
	class StateProvider

		def is_req_already_processed(chat_id, req_id)
			return false if req_id == nil

		end

		def update_last_processed_req_id(chat_id, req_id)
			return false if req_id == nil
		end

		def get_current_state(chat_id)
			:none
		end

		def update_state_for(chat_id, state)
			
		end

		def update_last_processed_request(chat_id, req_id)
			
		end

	end

end