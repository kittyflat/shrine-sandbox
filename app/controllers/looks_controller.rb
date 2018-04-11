class LooksController < ApplicationController
  def index
    @looks = Look.all.reverse
  end

  def show
    @look = Look.find(params[:id])
  end

  def new
    @look = Look.new
  end

  def edit
    @look = Look.find(params[:id])
  end

  def create
    @look = Look.new(look_params)
    if @look.save
      redirect_to @look
    else
      render 'new'
    end
  end

  def update
    @look = Look.find(params[:id])
    if @look.update(look_params)
      redirect_to @look
    else
      render 'edit'
    end
  end

  def destroy
    @look = Look.find(params[:id])
    @look.destroy
    redirect_to looks_path
  end

  private

  def look_params
    params.require(:look).permit(:user_id, :photo)
  end
end
