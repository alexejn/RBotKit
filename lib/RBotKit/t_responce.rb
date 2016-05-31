module RBotKit 
 
  class TRep
    require "rest-client"
    require 'json' 
    require 'i18n' 
    class << self; attr_accessor :chat_id end 
    attr_accessor :chat_id

    @@test_mode = false 
    def set_test_mode(v)
      @@test_mode = v
    end

    def initialize(chat_id, kb_builder = nil)
      @chat_id = chat_id
      @kb_builder = kb_builder 
      @payload = {chat_id: @chat_id}
    end

    def call(locale = nil)
      cl = I18n.locale.to_s
      if locale == nil || locale.to_s == cl
        @proc_block.call 
      else
        I18n.locale = locale
        @proc_block.call 
        I18n.locale = cl 
      end 
    end

    def loc_txt(key, prms = {}) 
      @proc_block = Proc.new {   
            if @@test_mode 
              test_call("loc_txt locale:#{I18n.locale} key:#{key} prms:#{prms}")
            else 
              @payload = {chat_id: @chat_id, text: I18n.t(key, prms)}
              set_payload_keyboard
              tel_send_message 
            end 
      } 
      itself
    end

    def loc_photo_file(photofile, ckey, cprms = {})   
      @proc_block = Proc.new {  
          if @@test_mode 
            test_call("loc_photo_file locale:#{I18n.locale} ckey:#{ckey} cprms:#{cprms} photofile:#{photofile}")
          else
            @payload = {chat_id: @chat_id, caption: I18n.t(ckey, cprms), photo: File.new(photofile, 'rb') }
            set_payload_keyboard
            tel_send_photo  
          end  
      }
      itself
    end

    def txt(text)  
      @proc_block = Proc.new {   
            if @@test_mode 
              test_call("txt text:#{text}")
            else
              @payload = {chat_id: @chat_id, text: text}
              set_payload_keyboard
              tel_send_message 
            end 
      } 
      itself
    end

    def photo_file(photofile, caption)  
      @proc_block = Proc.new {  
          if @@test_mode 
            test_call("photo_file caption:#{caption} photofile:#{photofile}") 
          else 
            @payload = {chat_id: @chat_id, caption: caption, photo: File.new(photofile, 'rb') }
            set_payload_keyboard
            tel_send_photo 
          end
      } 
      itself
    end

    private  

    def test_call(text)
      kbputs = @kb_builder == nil ? "" : " kb:#{@kb_builder.call()}"
      STDOUT.puts "chat_id:#{@chat_id}#{kbputs} #{text}" 
    end

    def set_payload_keyboard
      @payload[:reply_markup] = @kb_builder.call().to_json if @kb_builder != nil  
    end

    def tel_send_message 
      RestClient::Request.execute(method: :post, url: "https://api.telegram.org/#{RBotKit.bot_key}/sendMessage",
                            timeout: 10,
                            payload: @payload.to_json , 
                            headers: {content_type: "application/json; charset=utf-8"})  
    end

    def tel_send_photo
      RestClient::Request.execute(method: :post, url: "https://api.telegram.org/#{RBotKit.bot_key}/sendPhoto",
                    timeout: 10,
                    payload: @payload, 
                    multipart: true ) 
    end
    
  end 
end
