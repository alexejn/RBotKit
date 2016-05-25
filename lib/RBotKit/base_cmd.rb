module RBotKit
 
	class BaseCmd
		class << self; attr_accessor :request end
		class << self; attr_accessor :responces end
		class << self; attr_accessor :state_provider end

 		 @request = nil  
 		 @state_provider = nil  
 		 @responces = nil 

 		 attr_accessor :request
 		 attr_accessor :responces
 		 attr_accessor :state_provider

 		 def before_init
 		 	
 		 end

 		 def before_validate 
 		 end

 		 def handle  
 		 end
 
 		 def new_ret_resp(kb_builder = nil)
 		 		new_resp(@request.chat_id, kb_builder)
 		 end

 		 def new_resp(chat_id, kb_builder = nil)
 		 		resp = TRep.new(chat_id, kb_builder)
 		 		add_resp resp 
 		 		resp
 		 end

 		 def add_resp(resp)
 		 	@responces = [] if @responces == nil 
 		 	@responces << resp
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
