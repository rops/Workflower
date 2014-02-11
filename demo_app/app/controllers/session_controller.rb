class SessionController < ApplicationController
  def first
  end

  def valid_login(u,p)
    if u.to_s == '' || p.to_s == '' || 
      false
    else
      true
    end
  end

  def valid_answer(a)
    true
  end

  def second	
  	session[:username] = params['username']
  	session[:password] = params['password']
  end

  def login
  	user = User.find_by_username(session[:username])
  	if user && user.password == session[:password]
      #login
  		session[:user_id] = user.id
  		session.delete(:username)
  		session.delete(:password)
  		session.delete(:check)
  	else
      #error
  		flash[:alert] = "Wrong Credentials!" 
      Workflow.workflow_violated = true 		
  	end
  	
  	redirect_to '/'
  end

  def logout
  	session.delete(:user_id)
  	redirect_to '/'
  end
end
