require 'spec_helper' 

describe RBotKit do
	#$cli = Mongo::Client.new([ '127.0.0.1:27017' ])
	 
	class TestStateProv < RBotKit::StateProvider
	  def get_current_state(chat_id)
			:new
		end
	end

  class NewCmd < RBotKit::BaseCmd
	  def handle  
	  	p 'new'
 	  end
	end

  class HelpCmd < RBotKit::BaseCmd
	  def handle  
	  	p 'handle'
 	  end
	end

  it 'has a version number' do
    expect(RBotKit::VERSION).not_to be nil
  end

  it 'parse telegramm request ' do
  	data =  {update_id: 1, message: { chat: {id: 22}, text: 'sda'}, from: {id: 3, first_name: 'Alexey' }}
     expect(RBotKit::tel_parse_data(data)).not_to be nil
  end

  it 'call right cmd' do 
    req = RBotKit::Request.new(1, 1, 1, '/new', 'alexey')  
    sp = TestStateProv.new
    cases = [
    	RBotKit.new_case(:new, '/new', "NewCmd"),
    	RBotKit.new_case(:help, '/help', "HelpCmd")
    ]
    cm = RBotKit::CommandManager.new(sp, cases) 
    cm.process_request(req)

  end

  it 'command manager' do

		
    req = RBotKit::Request.new(1, 200630560, 200630560, '/new', 'alexey')  
    sp = RBotKit::StateProvider.new
    cases = [RBotKit.new_case(:none, '/new', "BaseCmd")]
    cm = RBotKit::CommandManager.new(sp, cases) 
    cm.process_request(req)

  end

end
