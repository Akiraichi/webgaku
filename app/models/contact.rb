class Contact < ApplicationRecord
  # attr_accessor :name, :email, :phone, :message
require 'line/bot' 
  validates :name,   length: { minimum: 3, :too_short => '名前を入力して下さい。'}
  validates :email,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  validates :phone,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  # validates_numericality_of :phone, { :message => '電話番号は数字で入力して下さい。'}
  validates :message, :presence => { :message => '問い合わせ内容を入力して下さい。'}
  after_create do
    $ttx=Contact.last.message
    client.push_message(ENV["PUSH_TO_ID"], text_message($ttx))
  end
end