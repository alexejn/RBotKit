require "RBotKit/version"
require "RBotKit/responce_builder" 
require "RBotKit/base_cmd"
require "RBotKit/state_provider"

module RBotKit
 
  Request = Struct.new(:id, :chat_id, :user_id, :text, :username) 
 
  def self.tel_parse_data(data)
  	id = data[:update_id]
  	mes = data[:message]
  	usr = data[:from]
		chat_id = mes[:chat][:id].to_s
		user_id = usr[:id]
		username = usr[:first_name]
		text = mes[:text] != nil ? mes[:text].strip : nil   
  	req = Request.new(id, chat_id, user_id, text, username)  
  end
 

  CommandCase = Struct.new(:state, :cmdtext, :cmdclass) 

  def self.new_case(state, cmdtext, cmdclass) 
    CommandCase.new(state, cmdtext, cmdclass) 
  end

  class UserError < Exception
  end

  class CommandManager  
    @@cmd_classprefix = "RBotKit::"  

    def initialize(state_provider, caces)
      @state_provider = state_provider
      @caces = caces
    end
  
  	def process_request(req)
  		return if req.text == nil 
      return if @state_provider.is_req_already_processed(req.chat_id, req.id)

      @state_provider.update_last_processed_req_id(req.chat_id, req.id)

      state = @state_provider.get_current_state(req.chat_id)

      cmdCase = nil  
      @caces.each do |cc| 
        cmdCase = cc.state == state && cc.cmdtext == req.text ? cc : nil
        break if cmdCase != nil
      end


      return if cmdCase == nil 

      begin
        cmdHandel = Object::const_get("#{@@cmd_classprefix}#{cmdCase.cmdclass}").new
        cmdHandel.request = req  
        cmdHandel.before_init()
        cmdHandel.before_validate() 
        cmdHandel.handle() 
        responces = cmdHandel.responces 

        return if responces == nil || responces.empty?

        responces.each do |res|
          p 'call'
          res.call
        end

      rescue UserError => e
        p "UserError #{e} "
        #eresp = ResponceBuilder.tel_text_resp(req.chat_id, e)
        return
      rescue Error => e
        p "Exc #{e} "
        return nil
      end

  	end
 
  end

  def self.val_not_nil data
    
  end
end