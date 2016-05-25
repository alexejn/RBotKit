require "RBotKit/version"
require "RBotKit/t_responce" 
require "RBotKit/base_cmd"
require "RBotKit/state_provider"
require "RBotKit/locale_provider"


module RBotKit
  
  @@bot_key = ""

  def self.set_bot_key(bk)
  	@@bot_key = bk
  end

  def self.bot_key
    @@bot_key
  end

  Request = Struct.new(:id, :chat_id, :user_id, :text, :username) 
  RequestCallback = Struct.new(:id, :chat_id, :user_id, :text, :username) 
 
  def self.tel_parse_data(data)
  	id = data[:update_id] 
  	mes = data[:message]
  	if mes != nil 
  		usr = mes[:from]
			chat_id = mes[:chat][:id].to_s
			user_id = usr[:id]
			username = usr[:first_name]
			text = mes[:text] != nil ? mes[:text].strip : nil   
  		req = Request.new(id, chat_id, user_id, text, username)  
  	else 
    	cb = data[:callback_query]
    	if cb != nil
  			mes = cb[:message]
				chat_id = mes[:chat][:id].to_s if mes != nil 
    		usr = cb[:from]
    		user_id = usr[:id]
    		username = usr[:first_name]
    		text = cb[:data]
  			req = RequestCallback.new(id, chat_id, user_id, text, username)  
    	end
  	end
  end
 

  CommandCase = Struct.new(:state, :cmdtext, :cmdclass) 

  def self.new_case(state, cmdtext, cmdclass) 
    CommandCase.new(state, cmdtext, cmdclass) 
  end

  class UserError < Exception
  end

  class CommandManager  
    @@cmd_classprefix = "RBotKit::"  
    @@is_test_mode = false 

    def self.set_cmd_classprefix(kp)
  		@@cmd_classprefix = kp
  	end

    def self.set_is_test_mode()
      @@is_test_mode = true
    end

    def initialize(state_provider, caces, inlinecases, locale_provider = nil)
      @state_provider = state_provider
      @caces = caces
      @inlinecases = inlinecases
      @locale_provider = locale_provider == nil ? LocaleProvider.new : locale_provider
    end
  
  	def process_request(req)
  		return if req.text == nil 
      return if @state_provider.is_req_already_processed(req.chat_id, req.id)

      @state_provider.update_last_processed_req_id(req.chat_id, req.id)

      state = @state_provider.get_current_state(req.chat_id)
      p "STATE = #{state}"
      cmdCase = nil  

      arrs = req.class == RequestCallback ? @inlinecases : @caces 

      arrs.each do |cc| 
      	in_state = cc.state.class == Array ? cc.state.include?(state) : cc.state == state  
      	if in_state || cc.state == :any 
      		if cc.cmdtext.class == Hash 
      			regexp = cc.cmdtext[:regexp] 
      			cmdCase = cc if regexp != nil && regexp.match(req.text) 
      		elsif  cc.cmdtext.class == Symbol && cc.cmdtext == :any
      			cmdCase = cc
      		else 
      			cmdCase = cc if cc.cmdtext == req.text 
      		end  
      	end 

        break if cmdCase != nil
      end 

      return if cmdCase == nil 
      p "CMD = #{cmdCase} #{@@cmd_classprefix}#{cmdCase.cmdclass}"
      begin

        cmdHandel = Object::const_get("#{@@cmd_classprefix}#{cmdCase.cmdclass}").new
        cmdHandel.request = req  
        cmdHandel.state_provider = @state_provider
        cmdHandel.before_init()
        cmdHandel.before_validate() 
        cmdHandel.handle() 
        responces = cmdHandel.responces 

        return if responces == nil || responces.empty?

        responces.each do |res|
          locale = @locale_provider.get_locale_for(res.chat_id) 
          res.set_test_mode(@@is_test_mode)
          res.call(locale)
        end

      rescue UserError => e
        p "UserError #{e.message} "
        eresp = TRep.new(req.chat_id)
        eresp.txt(e.message)
        locale = @locale_provider.get_locale(req.chat_id)
        eresp.set_test_mode(@@is_test_mode)
        eresp.call(locale)
        return
      rescue  => e
        p "Exc #{e} "
        return
      end

  	end
 
  end

end