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
            elsif text == "雑談しよう"
              message = text
            elsif text == "今の気温は？"
              message = env_sensor
            end
          client.reply_message(event['replyToken'], text_message(message))
        end
      end
    }
    head :ok
  end

  def env_sensor
    uri = "http://abe7d91d.ngrok.io/get"
    client = HTTPClient.new
    request =  client.get(uri)
    response = JSON.parse(request.body)

    tmp = response["tmp"]
    atomPress = response["atomPress"]
    humidity = response["humidity"]

    if tmp.to_i>28.0
      extra="少し暑いですね"
    elsif tmp.to_i<=28.0 && tmp.to_i >= 24.0
      extra="快適な気温ですね"
    else 
      extra="少し寒いですね"
    end

    message="現在の気温は
              #{tmp}度
              気圧：#{atomPress}hPa
              湿度：#{humidity}%
              です！
              #{extra}"
    return message
  end

#   def chat(text)
#   a_key = 
#   uri = "https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/registration?APIKEY=#{a_key}"
#   body = { "botId": "Chatting", "appKind": "Smart Phone" }
#   client = HTTPClient.new()
#   response = client.get(uri)
#   puts response.status
#   puts response.body
#   res = client.post(uri, body, 'Content-Type' => 'application/json')
#   puts res.body
#   response = client.get(uri)
#   puts response
#   puts response.body
#   response = JSON.parse(response.body)
#   puts response
#   return response
# end

  def inquiry_count
    message="現在の問い合わせ総数は#{Contact.count}件です！"
    return message
  end

  def help
    message="こんにちは学生会サポートBotのmiraitoです！\n以下のスキルに対応しています！
                \n[常時]Webページへお問い合わせがあった場合は連絡します！
                \n[1]全ての問い合わせを教えて
                \n[2]問い合わせ総数を教えて
                \n[3]今日の天気は？
                \n[4]今の気温は？
            \n将来的にはmiraito経由でWebサイトのコンテンツ更新も可能です" 
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
  
end