module SessionsHelper
	def sign_in(user)
		#Cookie provided automagically by Rails
		#It can be used as a hash as well
		cookies.permanent[:remember_token] = user.remember_token
		self.current_user = user		
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	#Only used to set the current user.
	def current_user=(user)
		@current_user = user
	end

	#Only used to retrieve the value of @current_user
	def current_user
		#If @current_user == nil, then retrieve it from DB using remember_token 
		#stored in the cookie. Otherwise, do nothing (just return the current value).
		@current_user ||= User.find_by_remember_token(cookies[:remember_token])
	end

	def signed_in?
		#The function.
		!current_user.nil?
	end
end
