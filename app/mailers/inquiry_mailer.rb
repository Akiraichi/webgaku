class InquiryMailer < ActionMailer::Base

  ##### 送信元アドレス
  default from: "example@example.com"
  ##### 送信先アドレス
  default to: "akiraichi5430@gmail.com"

  def received_email(inquiry)
    ##### メール件名
    mail_subject = "Ruby on Rails 5で作った問い合わせフォームから問い合わせがありました"

    @inquiry = inquiry
    mail(:subject => mail_subject)
  end

end