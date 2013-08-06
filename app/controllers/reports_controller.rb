class ReportsController < ApplicationController

	skip_before_filter :verify_authenticity_token, :only => [:create]

	def show
		@title = "Ver reporte"
		@report = current_user.nodes.find(params[:node_id]).reports.find(params[:id])
		@report.body = File.open(@report.file_path).read
	end

	#It lists all the reports of one node.
	def index
		@node = current_user.nodes.find(params[:node_id])
		@reports = @node.reports
		@title = "Todos los reportes de #{current_user.nodes.find(params[:node_id]).fqdn}"
	end

	def download
		send_file(current_user.nodes.find(params[:node_id])).reports.find(params[:id]).file_path)
	end

	def create
		fqdn = "#{request.host}.#{request.domain}"

		report_name = "#{Time.now.to_i}_#{fqdn}"
		report_path = "C:\\Users\\jesus\\Desktop\\Pasantia\\Proyecto\\bancaplus-postventa\\BM-CM\\node_reports\\#{fqdn}\\#{report_name}"
		f = File.new(report_path, "w+")
		f.write(request.body)
		f.close

		r = Report.new
		r.file_path = report_path
		r.name = report_name
		#Push the report into the database
		current_user.nodes.find_by_fqdn(fqdn).reports << r
	end

end
