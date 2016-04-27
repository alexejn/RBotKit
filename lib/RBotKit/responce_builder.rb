module RBotKit 
	module ResponceBuilder 
		require "rest-client"
		require 'json'

		 @@bot_key = "bot177844393:AAFuw3_6FkYK0sTXkEzQzMvqTkpJVAMQQnw"

		 class Responce 
 		 		@proc_block = nil   
 		 		attr_accessor :proc_block
 
		 	def call
		 		resp =  @proc_block.call
		 		p resp
		 	end 
		 end


 		 def self.tel_text_resp(chat_id, text)
 		 			resp = Responce.new
 		 			resp.proc_block =  Proc.new {  
 		 			 		RestClient::Request.execute(method: :post, url: "https://api.telegram.org/#{@@bot_key}/sendMessage",
                            timeout: 10,
                            payload: {chat_id: chat_id, text: text}.to_json , 
                            headers: {content_type: "application/json; charset=utf-8"}) 
                             }
 		 			return resp
 		 end
 		
 		 def self.tel_filephoto_resp(chat_id, caption, photofile)
 		 			resp = Responce.new
 		 			resp.proc_block =  Proc.new {  
 		 			 		RestClient::Request.execute(method: :post, url: "https://api.telegram.org/#{@@bot_key}/sendPhoto",
                            timeout: 10,
                            :payload => { 
                            	chat_id: chat_id,
                            	caption: caption,  
                            	photo: photofile
                            }, 
                            multipart: true ) 
                             }
 		 			return resp
 		 end

	end 
end
