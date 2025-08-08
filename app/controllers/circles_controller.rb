class CirclesController < ApplicationController
  before_action :set_circle, only: [ :update ]

  # PUT /circles/:id
  def update
    if @circle.update(circle_params)
      render :update, status: :ok
    else
      render json: { errors: @circle.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_circle
    @circle = Circle.find(params[:id])
  end

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
