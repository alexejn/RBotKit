module RBotKit
 
	class BaseCmd
		class << self; attr_accessor :request end
		class << self; attr_accessor :responces end

 		 @request = nil  
 		 @responces = nil 

 		 attr_accessor :request
 		 attr_accessor :responces

 		 def before_init
 		 	
 		 end

 		 def before_validate 
 		 end

 		 def handle  
 		 end


 		 def resp_return_msg txt
 		 	@responces = [] if @responces == nil 
 		 	@responces << ResponceBuilder.tel_text_resp(@request.chat_id, txt)
 		 end

 	   def resp_return_photofile(filepath, caption)
 		 	@responces = [] if @responces == nil 
 		 	@responces << ResponceBuilder.tel_filephoto_resp(@request.chat_id, caption, File.new(filepath, 'rb'))
 		 end

 		 def err_if_true(bv, msg)
 		 		raise UserError.new(msg) if bv
 		 end

 		 def err_if_false(bv, msg)
 		 		raise UserError.new(msg) if !bv
 		 end

 		 def err_if_nil(bv, msg)
 		 		raise UserError.new(msg) if bv == nil 
 		 end
	end

end
