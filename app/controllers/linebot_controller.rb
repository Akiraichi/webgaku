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
            text = event.message['text']
            message = text
            if text == "問い合わせ数を教えて"
              message=inquiry_count
            elsif text == "help"
              message=help
            elsif text == "全ての問い合わせを教えて"
              message=inquiry_all
            end
          client.reply_message(event['replyToken'], text_message(message))
        end
      end
    }
    head :ok
  end

  def inquiry_count
    message="現在の問い合わせ総数は#{Contact.count}件です！"
    return message
  end
  def help
    message="こんにちは学生会サポートBotのmiraitoです！\n以下のスキルに対応しています！
                \n[常時]Webページへお問い合わせがあった場合は連絡します！
                \n[1]全ての問い合わせを教えて
                \n[2]問い合わせ総数を教えて
                \n[3]おうむ返しして
                \n[4]雑談しよう" 
  end
  def inquiry_all
    contacts=Contact.all
    messagePlus = ""
    for contact in contacts
      message = "名前：#{contact.name}\nタイトル：#{contact.phone}\nメッセージ：#{contact.message}\n\n"
      messagePlus += message
    end
    return messagePlus
end