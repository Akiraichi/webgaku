class AboutController < ApplicationController
  def index
    @members = Member.all
    render 'about'
  end
end
