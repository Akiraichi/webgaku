class Contact < ApplicationRecord
  attr_accessor :name, :email, :phone, :message

  validates :name,   length: { minimum: 3, :too_short => '名前を入力して下さい。'}
  validates :email,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  validates :subject,  length: { minimum: 3, :too_short => 'メールアドレスを入力して下さい。'}
  validates_numericality_of :phone, { :message => '電話番号は数字で入力して下さい。'}
  validates :message, :presence => { :message => '問い合わせ内容を入力して下さい。'}
end
