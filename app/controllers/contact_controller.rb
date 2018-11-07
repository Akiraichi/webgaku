class ContactController < ApplicationController
  def index
    @contact = Contact.new
    render 'contact'
  end
  ##### 問い合わせフォームから入力された内容をチェックする
  def confirm
    @contact = Contact.new(contact_params)
    if @contact.valid?
      # 入力内容に問題ない場合、問い合わせ確認画面を表示
      render :action => 'confirm'
    else
      # 入力内容に問題ある場合、問い合わせ画面を再表示
      render :action => 'index'
    end
  end

  ##### 問い合わせ完了画面の処理
  def thanks
    # 問い合わせ内容をメール送信
    @contact = Contact.new(contact_params)
    ContactMailer.received_email(@contact).deliver

    # 問い合わせ内容をChatWorkへ通知
    @chatwork = ContactChatwork.new
    @chatwork.push_chatwork_message(@contact)

    # 問い合わせ完了画面を表示する
    render :action => 'thanks'
  end

  ##### Strong Parametersで問い合わせ画面からの入力を許可するリクエストパラメータを指定する
  def contact_params
    params.require(:contact).permit(
      :name, :email, :phone, :message
    )
  end
end