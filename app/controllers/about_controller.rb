class AboutController < ApplicationController
  def index
    @members = Member.all
    render 'about'
  end


  def downloadpdf
    file_name="1.pdf"
    filepath = Rails.root.join('public',file_name)
    stat = File::stat(filepath)
    send_file(filepath, :filename => file_name, :length => stat.size)
  end
end
