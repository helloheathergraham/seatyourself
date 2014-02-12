class ReservationsController < ApplicationController
before_filter :load_restaurant
  def show
    @reservation = Reservation.find(params[:id])
  end

  def create
    @reservation = @restaurant.reservations.build(reservation_params)
    @reservation.user_id = current_user.id

    if @reservation.time.strftime("%k").to_i < 20 && @reservation.time.strftime("%k").to_i > 11  
      @reservations = Reservation.all
      seats_total = @reservation.party_size
      @reservations.each do |r|
        if r.date == @reservation.date && r.restaurant_id == @reservation.restaurant_id && r.time.strftime("%I") == @reservation.time.strftime("%I")
          seats_total += r.party_size
        end
      end

      if seats_total <= 100
      	@reservation.save
      	redirect_to users_path, :notice => 'Reservation created successfully' 
      else
        redirect_to users_path, :notice => 'No available space'
      end

    else
      redirect_to users_path, :notice => 'Not Open'
    end
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy
    redirect_to users_path
  end

  private
  def reservation_params
    params.require(:reservation).permit(:time, :date, :party_size, :user_id, :restaurant_id)
  end

  def load_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id]) if params[:restaurant_id] != nil
  end
end
