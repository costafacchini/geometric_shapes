class CirclesController < ApplicationController
  before_action :set_circle, only: [ :update, :destroy ]

  # GET /circles
  def index
    @circles = Circle.all

    @circles = @circles.where(frame_id: params[:frame_id]) if params[:frame_id].present?

    if params[:center_x].present? && params[:center_y].present? && params[:radius].present?
      center_x = params[:center_x].to_f
      center_y = params[:center_y].to_f
      search_radius = params[:radius].to_f

      @circles = @circles.select do |circle|
        distance_from_center = Math.sqrt((circle.x - center_x)**2 + (circle.y - center_y)**2)
        distance_from_center + circle.radius <= search_radius
      end
    end

    render :index
  end

  # PUT /circles/:id
  def update
    if @circle.update(circle_params)
      render :update, status: :ok
    else
      render json: { errors: @circle.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /circles/:id
  def destroy
    @circle.destroy
    head :no_content
  end

  private

  def set_circle
    @circle = Circle.find(params[:id])
  end

  def circle_params
    params.require(:circle).permit(:x, :y, :diameter)
  end
end
