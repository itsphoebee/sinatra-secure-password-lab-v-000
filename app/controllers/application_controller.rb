require "./config/environment"
require "./app/models/user"
require 'pry'
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    user = User.new(username:params[:username], password:params[:password], balance:0)
    if user.save
      redirect '/login'
    else
      redirect '/failure'
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(username:params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/success" do
    if logged_in?
      erb :success
    else
      redirect "/login"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  patch 'deposit/:id' do
    @user = User.find(params[:id])
    @user.balance += params[:deposit].to_f
    @user.save

  end
  +  patch '/deposit/:id' do
 +    @account = User.find(params[:id])
 +    if @account.balance == nil
 +      @account.balance = params[:deposit]
 +    else
 +      @account.balance += params[:deposit].to_f
 +    end
 +    @account.save
 +    redirect '/account'
 +  end
 +
 +  patch '/withdraw/:id' do
 +    @account = User.find(params[:id])
     if @account.balance == nil || @account.balance < params[:withdraw].to_f
       redirect '/error'
     else
     @account.balance = @account.balance - params[:withdraw].to_f
       @account.save
     end
     redirect '/account'
  end



  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

  end

end
