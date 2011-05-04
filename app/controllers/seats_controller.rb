class SeatsController < ApplicationController

  def GetGlobalMessages
    # @lastMessageID = session["lastMessageID"]

    @messages = Message.where("user_id_to IS NULL AND id > " + (session[:lmID] ? session[:lmID] : 1).to_s + " AND created_at > ?", Time.now.strftime("%Y-%m-%d")).order("id DESC")

    
    if (!Message.last == nil)
	   session[:lmID] = Message.last.id
    end
    @messages.each do |m|
        @gconversation = "#{@gconversation}\n"+ (m.user_id_from ? User.find(m.user_id_from).username : 'guest') + ": #{m.message}"
    end
    if @gconversation
       @gconversation = @gconversation.first(4000)
    end 

    respond_to do |format|
        format.js { render :action => "GetGlobalMessages.js.erb" }
       # format.js #
    end
  end


  def createglobalmessage
    @counter = 0
    @seats = Seat.all
    @message = Message.new
    @message.message = params[:g_message]
    @message.user_id_from = params[:from] 
    @message.user_id_to = nil
    @message.save
    
    @messages = Message.where("user_id_to IS NULL AND created_at > ?", Time.now.strftime("%Y-%m-%d")).order('id desc')

    @messages.each do |m|
      @gconversation = "#{@gconversation}\n"+ (m.user_id_from ? User.find(m.user_id_from).username : 'guest') + ": #{m.message}"
    end
    if @gconversation
       @gconversation = @gconversation.first(4000)
    end 

    respond_to do |format|
        format.html { render :action => "index.html.erb" }
	format.js # 
    end
  end

  # GET /seats
  # GET /seats.xml
  def index
    @counter = 0
    @seats = Seat.all(:order =>'id')

    @messages = Message.where("user_id_to IS NULL AND created_at > ?", Time.now.strftime("%Y-%m-%d")) 

    @messages.each do |m|
      @gconversation = "#{@gconversation}\n"+ (m.user_id_from ? User.find(m.user_id_from).username : 'guest') + ": #{m.message}"
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @seats }
    end
  end

  # GET /seats/1
  # GET /seats/1.xml
  def show
    @seat = Seat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @seat }
    end
  end

  # GET /seats/new
  # GET /seats/new.xml
  def new
    @seat = Seat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @seat }
    end
  end

  # GET /seats/1/edit
  def edit
    @seat = Seat.find(params[:id])
  end

  # POST /seats
  # POST /seats.xml
  def create
    @seat = Seat.new(params[:seat])

    respond_to do |format|
      if @seat.save
        format.html { redirect_to(@seat, :notice => 'Seat was successfully created.') }
        format.xml  { render :xml => @seat, :status => :created, :location => @seat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @seat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /seats/1
  # PUT /seats/1.xml
  def update
    @seat = Seat.find(params[:id])

    respond_to do |format|
      if @seat.update_attributes(params[:seat])
        format.html { redirect_to(@seat, :notice => 'Seat was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @seat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /seats/1
  # DELETE /seats/1.xml
  def destroy
    @seat = Seat.find(params[:id])
    @seat.destroy

    respond_to do |format|
      format.html { redirect_to(seats_url) }
      format.xml  { head :ok }
    end
  end

  # PUT /seats/1
  # PUT /seats/1.xml
  def sit
    @seat = Seat.find(params[:id])
		@prevSeat = Seat.new # Pass in at least a new seat to format.js 
		
    if session[:user_id] == nil
        flash[:alert] = "You must login to take a seat"
    end
    
    # Check if seat is available
    if @seat.user_id == nil 
      
      # Find all seats with user id first and remove
      @seatsOccupied = Seat.where(:user_id=>session[:user_id])
      
      if @seatsOccupied != nil
          @seatsOccupied.each do |s|
            # Unoccupy all seats currently occupied
            s.user_id = nil
            s.save
						
						# Record the previous taken seat id
						@prevSeat = s
          end
      end 
      
      # Occupy a seat and save
      @seat.user_id = session[:user_id] 
      @seat.save
		
    else
      # Can't sit, page will rerender with flash alert
      flash[:alert] = "Seat ##{@seat.id} is currently occupied"
    end

    # After attempting to sit, get all seats to render
    @seats = Seat.all 

		respond_to do |format|
			format.html {redirect_to(seats_url)}
			format.xml  {render :xml => @seats }
			format.js 	{render 'sit.js.erb', :object => @seat, :object => @prevSeat, :object => @seats}
		end
			
 end

end
