class Contact < ApplicationRecord
  # attr_accessor :name, :email, :phone, :message
require 'line/bot' 
  validates :name,   length: { minimum: 3, :too_short => '名前を入力して下さい。'}
  validates :email,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  validates :phone,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  # validates_numericality_of :phone, { :message => '電話番号は数字で入力して下さい。'}
  validates :message, :presence => { :message => '問い合わせ内容を入力して下さい。'}
  
  def text_message(text)
    {
        "type" => "text",
        "text" => text
    }
  end

  #問い合わせフォームに投稿が来ると実行
  after_create do
    # Lineボットのクライアント設定
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
    #textを設定
    contact=Contact.last
    text = "名前：#{contact.name}\nメールアドレス：#{contact.email}\nタイトル：#{contact.phone}\nメッセージ：#{contact.message}"
    # lineボットから送信
    @client.push_message(ENV["PUSH_TO_ID"], text_message(text))
  end
end