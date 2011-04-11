class SessionsController < ApplicationController

  # Create
  #
  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:user_id] = user.id
      session[:start_time] = Time.now
      redirect_to '/enter', :notice => "Hi " + user.fname + " " + user.lname + "!"
    else
      flash.now[:alert] = "Invalid login/password combination"
      render :action => 'new'
    end
  end

  # Destroy
  #
  def destroy
    # Remove seated person
    @seat = Seat.where(:user_id=>session[:user_id])
    
    @seat.each do |s|
      s.user_id = nil
      s.save
    end if @seat != nil

    reset_session
    redirect_to '/enter', :notice => "Good bye!"
  end

end
