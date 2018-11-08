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
            end
          client.reply_message(event['replyToken'], text_message(ttest))
        end
      end
    }
    head :ok
  end
    
  def ttest
    uri = "http://703d4280.ngrok.io/get"
    client = HTTPClient.new
    request =  client.get(uri)
    response = JSON.parse(request.body)
    return response[:temp].to_s
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
                \n[3]今日の天気を教えて
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

  def zatsudan
    params = URI.encode_www_form({key: "95a1bf46a5df15d125a0", message: "おはよう"})
    uri = URI.parse("http://zipcloud.ibsnet.co.jp/api/search?#{params}")
    @query = uri.query
    # 新しくHTTPセッションを開始し、結果をresponseへ格納
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      # 接続時に待つ最大秒数を設定
      http.open_timeout = 5
      # 読み込み一回でブロックして良い最大秒数を設定
      http.read_timeout = 10
      # ここでWebAPIを叩いている
      # Net::HTTPResponseのインスタンスが返ってくる
      http.get(uri.request_uri)
    end
    # 例外処理の開始
    begin
      # responseの値に応じて処理を分ける
      case response
      # 成功した場合
      when Net::HTTPSuccess
        # responseのbody要素をJSON形式で解釈し、hashに変換
        @result = JSON.parse(response.body)
        # 表示用の変数に結果を格納

      # 別のURLに飛ばされた場合
      when Net::HTTPRedirection
        @message = "Redirection: code=#{response.code} message=#{response.message}"
      # その他エラー
      else
        @message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
      end
    # エラー時処理
    rescue IOError => e
      @message = "e.message"
    rescue TimeoutError => e
      @message = "e.message"
    rescue JSON::ParserError => e
      @message = "e.message"
    rescue => e
      @message = "e.message"
    end
  end
  
end