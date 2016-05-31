require 'spec_helper' 
require 'i18n'
 
describe RBotKit do
	#$cli = Mongo::Client.new([ '127.0.0.1:27017' ])
	 RBotKit.set_bot_key "none"
   RBotKit::CommandManager.set_cmd_classprefix "RBotKit::"  
   RBotKit::CommandManager.set_is_test_mode
   I18n.available_locales = [:en, :ru]

	class TestStateProv < RBotKit::StateProvider
	  def get_current_state(chat_id)
			:new
		end
	end

   class TestLocaleProv < RBotKit::LocaleProvider
    def get_locale_for(chat_id)
      :ru
    end
  end

  class NewCmd < RBotKit::BaseCmd
	  def handle  
	  	STDOUT.puts "new"
 	  end
	end

  class HelpCmd < RBotKit::BaseCmd
	  def handle  
	  	STDOUT.puts "help"
 	  end
	end

  class LocaleCmd < RBotKit::BaseCmd
    def handle  
      new_ret_resp().loc_txt('key')
    end
  end

  class RealCmd < RBotKit::BaseCmd
	  def handle  
	  	new_ret_resp().txt 'RealCmd'
 	  end
	end

  it 'locale responce  work in test most' do   
    req = RBotKit::Request.new(1, 200630560, 200630560, '/real', 'alexey')  
    sp = TestStateProv.new
    cases = [
      RBotKit.new_case(:any, :any, "LocaleCmd"), 
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("chat_id:200630560 loc_txt locale:en key:key prms:{}")
    cm.process_request(req) 

    cm = RBotKit::CommandManager.new(sp, cases, [], TestLocaleProv.new)  
    STDOUT.should_receive(:puts).with("chat_id:200630560 loc_txt locale:ru key:key prms:{}")
    cm.process_request(req)  
  end

	it 'responce  work in test most' do   
    req = RBotKit::Request.new(1, 200630560, 200630560, '/real', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case(:any, :any, "RealCmd"), 
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("chat_id:200630560 txt text:RealCmd")
    cm.process_request(req) 
  end


  it 'has a version number' do
    expect(RBotKit::VERSION).not_to be nil
  end

  it 'parse telegramm request ' do
  	data =  {update_id: 1, message: { chat: {id: 22}, text: 'sda', from: {id: 3, first_name: 'Alexey' }}}
     expect(RBotKit::tel_parse_data(data)).not_to be nil
  end

  it 'call right cmd' do   
  	RBotKit::CommandManager.set_cmd_classprefix "RBotKit::"  
    req = RBotKit::Request.new(1, 200630560, 200630560, '/new', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case(:new, '/new', "NewCmd"),
    	RBotKit.new_case(:help, '/help', "HelpCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("new")
    cm.process_request(req)  
  end 

  it 'call right cmd when state is array' do   
    req = RBotKit::Request.new(1, 200630560, 200630560, '/new', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case([:new,:wow], '/new', "NewCmd"),
    	RBotKit.new_case([:about,:help], '/new', "HelpCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("new")
    cm.process_request(req)  
  end 

  it 'call right cmd when cmd is any' do   
    req = RBotKit::Request.new(1, 200630560, 200630560, '/new', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case([:new,:help], '/aba', "HelpCmd"),
    	RBotKit.new_case(:none, '/new', "HelpCmd"),
    	RBotKit.new_case(:any, :any, "NewCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("new")
    cm.process_request(req)  
  end 

   it 'call right cmd when state is any' do   
    req = RBotKit::Request.new(1, 200630560, 200630560, '/new', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case([:about,:help], '/new', "HelpCmd"),
    	RBotKit.new_case(:any, '/new', "NewCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("new")
    cm.process_request(req)  
  end 

   it 'call right command when regexp case' do    
    req = RBotKit::Request.new(1, 200630560, 200630560, "e2e4", 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case(:new, {regexp: /\A\/?[a-h][1-8][a-h][1-8]\z/ }, "NewCmd"),
    	RBotKit.new_case(:help, '/help', "HelpCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases, [])  
    STDOUT.should_receive(:puts).with("new")
    cm.process_request(req)  
  end 
end
