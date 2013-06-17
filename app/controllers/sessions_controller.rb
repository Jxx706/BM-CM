class SessionsController < ApplicationController

	#Sign in
	def new
		@title = "Iniciar sesión."
	end

	def create
		user = User.find_by_email(params[:session][:email].downcase)

		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_to user
		else
			#Lasts only for one request
			flash.now[:error] = "Combinación e-mail/contraseña inválida."
			render :action => :new
		end
	end

	#Sign out
	def destroy
		sign_out
		redirect_to root_path
	end
end
