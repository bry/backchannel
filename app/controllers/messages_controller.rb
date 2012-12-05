class MessagesController < ApplicationController

  before_filter :checksession, :only=> :show_private_chat 
 
  # GET /messages/private/{user_not_logged_in}/:to
  def bad_private_chat
    flash[:alert] = "Please log in before starting a private chat"
    redirect_to seats_path
  end

  # POST /messages
  # POST /messages.xml
  def show_private_chat 
    @messages = Message.where("user_id_to = ? AND created_at > ?", session[:user_id], session[:start_time]).order("id asc")
    @conversation = nil 

    @messages.each do |m|   
      @conversation = "#{@conversation}\n#{User.find(m.user_id_from).username.upcase}:#{m.message}"
    end

    if @conversation
      @conversation = @conversation.first(4000)    
    end

    respond_to do |format|
      format.html # show_private_chat.html.erb
      format.js 
      format.xml  { render :xml => @message }
    end
  end
  
  # GET /messages
  # GET /messages.xml
  def index
    @messages = Message.find_all_by_user_id_to(nil)
    
    @messages.each do |m|
      @gconversation = "#{@gconversation}\n#{User.find(m.user_id_from).username}:#{m.message}"
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.xml
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new
    respond_to do |format|
      format.html #{ redirect_to (messages_url) } # index.html.erb #  new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.xml
  def create
    @message = Message.new
    @message.message = params[:message]
    @message.user_id_from = params[:from]
    @message.user_id_to = params[:to]
    @message.save

    @messages = Message.where("user_id_to = ? AND created_at > ?", session[:user_id], session[:start_time]).order("id asc")
    @conversation = nil

    @messages.each do |m|
      @conversation = "#{@conversation}\n#{User.find(m.user_id_from).username.upcase}:#{m.message}"
    end

    if @conversation
      @conversation = @conversation.first(4000)
    end

    respond_to do |format|
      if @message.save
	format.js {render :action => "create_message.js.erb"} 
        format.html { redirect_to(show_private_chat_path) }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
       format.html { render :action => "new" }
       format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to(@message, :notice => 'Message was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url) }
      format.xml  { head :ok }
    end
  end


  private

  # checksession 
  def checksession
    if session[:user_id] == nil 
      redirect_to seats_path, :notice=>"Please log in"
    end
  end

end
