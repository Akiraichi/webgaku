class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def text_message(text)
    {
        "type" => "text",
        "text" => text
    }
  end
  
  public def memoPush(message)
    client.push_message(ENV["PUSH_TO_ID"], text_message(message))
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          contacts = Contact.all
          text = ""
          messages = []
          for contact in contacts
            text = "名前：#{contact.name}\nメールアドレス：#{contact.email}\nタイトル：#{contact.phone}\nメッセージ：#{contact.message}"
            messages << text_message(text)
          end
          # client.reply_message(event['replyToken'], messages)
          # memoPush("message")
        end
      end
    }

    head :ok
  end
end