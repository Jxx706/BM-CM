class ReportsController < ApplicationController

	skip_before_filter :verify_authenticity_token, :only => [:create]

	def show
	end

	def index
	end

	def download
	end

	def create
		#Main idea: Calculate the fqdn, then put the request.body in a file 
		#located in the node.directory_path.

		#Create the report object.
		fqdn = "#{request.host}.#{request.domain}"
	end
end
