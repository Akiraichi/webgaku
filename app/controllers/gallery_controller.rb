class GalleryController < ApplicationController
  def index
    render 'gallery'
  end
  def show
    # paramsで取得したidに基づいてrenderするファイルを変える
    id = params[:id]
    render "#{id}"
  end
end
