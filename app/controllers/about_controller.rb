class AboutController < ApplicationController
  def index
    # データベースからmemberモデルを取得
    @members = Member.all
    render 'about'
  end
end
