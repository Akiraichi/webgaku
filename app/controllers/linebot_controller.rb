class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]


  def client
    # line_clientのための初期設定
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  # jsonを利用するための前処理
  def text_message(text)
    {
        "type" => "text",
        "text" => text
    }
  end

  def callback
    # main処理部
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    # エラー処理
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
            if text=="Webページにアクセスしたい" || text=="web"
              message=web_site
            elsif text == "全ての問い合わせを教えて" || text=="all"
              message=inquiry_all
            elsif text == "問い合わせ数を教えて" || text=="count"
              message=inquiry_count
            elsif text == "LEDを点灯させて" || text=="led"
              led
              message = "LEDが点灯しました！"
            elsif text == "今の気温は？" || text=="tmp"
              message = env_sensor
            elsif text == "LINEボットの活用例について教えて" || text=="line"
              message=exampleLine
            elsif text == "使い方は？" || text=="help"
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

  # AIAPIとのチャット
  def chat(text)
    uri = "http://13ea3bc7.ngrok.io/pyt?text=#{text}"
    uri = URI.escape(uri)
    client = HTTPClient.new
    request =  client.get(uri)
    response = JSON.parse(request.body)
    return response["result"]
  end

  # LCDへのメッセージの表示
  def mozi(text)
    uri = "http://13ea3bc7.ngrok.io/mozi?text=#{text}"
    uri = URI.escape(uri)
    client = HTTPClient.new
    request =  client.get(uri)
  end

  # LEDの点灯
  def led
    uri = "http://13ea3bc7.ngrok.io/led"
    client = HTTPClient.new
    request =  client.get(uri)
  end

  # 各種センサー値の取得
  def env_sensor
    uri = "http://13ea3bc7.ngrok.io/get"
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

  def web_site
    message="こちらのサイトです！https://gakuseikai.herokuapp.com/ ちなみにサイト内容はフェイクなので信じないでくださいね
パソコンで見るように最適化されているのでスマホだと少し崩れてしまいます😢

星瞬祭の感想など問い合わせフォームにぜひ送ってくださいね😆"
    return message
  end
  # 問い合わせ総数の取得
  def inquiry_count
    message="現在の問い合わせ総数は#{Contact.count}件です！"
    return message
  end

  # helpメッセージの表示
  def help
    message="こんにちは学生会サポートBotのmiraitoです！\n以下のスキルに対応しています！
                \n[常時]Webページへお問い合わせがあった場合は管理者宛に連絡します
                \n[web]Webページにアクセスしたい
                \n[all]全ての問い合わせを教えて
                \n[count]問い合わせ総数を教えて
                \n[led]LEDを点灯させて
                \n[tmp]今の気温は？
                \n[line]LINEボットの活用例について教えて
                \n[help]使い方は？
            \nスキルを実行したいときは、スキルをそのまま入力するか番号を入力してください。
            \n例えば、今の気温は？と入力すると気温が返信されます。また、tmpと入力しても気温が返信されます。" 
  end

  # 全ての問い合わせの表示
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