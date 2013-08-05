class SessionsController < ApplicationController

	skip_before_filter :verify_authenticity_token, :only => [:create]

	#Sign in
	def new
		@title = "Iniciar sesion"
	end

	def create
		user = User.find_by_email(params[:session][:email].downcase)

		#User definitely exists and has been authenticated
		if user && user.authenticate(params[:session][:password])
			sign_in(user)
			redirect_to root_path
		else
			#Lasts only for one request
			flash.now[:error] = "Combinacion e-mail/clave invalida."
			render :action => :new
		end
	end

	#Sign out
	def destroy
		sign_out
		redirect_to root_path
	end

	protected 
		def handle_unverified_request
			true 
		end
end
