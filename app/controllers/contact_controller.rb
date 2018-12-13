class ContactController < ApplicationController
  def index
    # データベースからmemberモデルを取得
    @contact = Contact.new
    render 'contact'
  end
  
  def show
    # thanksビューをrenderする
    render 'thanks'
  end
end