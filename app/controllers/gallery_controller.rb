class GalleryController < ApplicationController
  def index
    render 'gallery'
  end
  def show
    id = params[:id]
    render "#{id}"
  end
end
