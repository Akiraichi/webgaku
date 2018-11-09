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
      # $userid = event["source"]["userId"]
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
            text = event.message['text']
            message = text
            if text=="Webページにアクセスしたい" || text=="1"
              message=web_site
            elsif text == "全ての問い合わせを教えて" || text=="2"
              message=inquiry_all
            elsif text == "問い合わせ数を教えて" || text=="3"
              message=inquiry_count
            elsif text == "LEDを点灯させて" || text=="4"
              led
              message = "LEDが点灯しました！"
            elsif text == "今の気温は？" || text=="5"
              message = env_sensor
            elsif text == "LINEボットの活用例について教えて" || text=="6"
              message=exampleLine
            elsif text == "help" || text=="7"
              message=help
            else
              message=chat(text)
            end
          client.reply_message(event['replyToken'], text_message(message))
        end
      end
    }
    head :ok
  end
  def exampleLine
    text = "チャットBOTサービスの方向性は、大きく
「サポート（問い合わせ）」
「エンゲージメント（ファン育成）」
「コンサルティング（課題解決・情報提供）」
の3つのカテゴリーに分けることができます。
具体的にはこちらのサイトをご覧ください https://backyard.imjp.co.jp/articles/chatbot"
    return text
  end

  def chat(text)
    uri = "http://061f20aa.ngrok.io/pyt?text=#{text}"
    uri = URI.escape(uri)
    client = HTTPClient.new
    request =  client.get(uri)
    response = JSON.parse(request.body)
    return response["result"]
  end

  def mozi(text)
    uri = "http://061f20aa.ngrok.io/mozi?text=#{text}"
    uri = URI.escape(uri)
    client = HTTPClient.new
    request =  client.get(uri)
  end

  def led
    uri = "http://061f20aa.ngrok.io/led"
    client = HTTPClient.new
    request =  client.get(uri)
  end

  def env_sensor
    uri = "http://061f20aa.ngrok.io/get"
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

    message="現在の気温は#{tmp}度
気圧：#{atomPress}hPa
湿度：#{humidity}%です！
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
  def web_sit
    message="こちらのサイトです！https://gakuseikai.herokuapp.com/ ちなみにサイト内容はフェイクなので信じないでくださいね
パソコンで見るように最適化されているのでスマホだと少し崩れてしまいます😢

星瞬祭の感想など問い合わせフォームにぜひ送ってくださいね😆"
    return message
  end
  def inquiry_count
    message="現在の問い合わせ総数は#{Contact.count}件です！"
    return message
  end

  def help
    message="こんにちは学生会サポートBotのmiraitoです！\n以下のスキルに対応しています！
                \n[常時]Webページへお問い合わせがあった場合は管理者宛に連絡します
                \n[1]Webページにアクセスしたい
                \n[2]全ての問い合わせを教えて
                \n[3]問い合わせ総数を教えて
                \n[4]LEDを点灯させて
                \n[5]今の気温は？
                \n[6]LINEボットの活用例について教えて
                \n[7]help
            \nスキルを実行したいときは、スキルをそのまま入力するか番号を入力してください。
            \n例えば、今の気温は？と入力すると気温が返信されます。また、4と入力しても気温が返信されます。" 
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