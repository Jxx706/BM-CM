require 'yaml'

class ReportsController < ApplicationController

	skip_before_filter :verify_authenticity_token, :only => [:create]

	def show
		@title = "Ver reporte"
		@report = current_user.nodes.find(params[:node_id]).reports.find(params[:id])
	end

	#It lists all the reports of one node.
	def index
		@node = current_user.nodes.find(params[:node_id])
		@reports = @node.reports
		@title = "Todos los reportes de #{current_user.nodes.find(params[:node_id]).fqdn}"
	end

	def download
		send_file(current_user.nodes.find(params[:node_id]).reports.find(params[:id]).file_path)
	end

	def create
		#fqdn = "#{request.host}.#{request.domain}"

		node = Node.find_by_ip(request.remote_ip)
		user = User.find(node.user_id)
		report_name = "#{Time.now.to_i}_#{request.remote_ip}_#{user.name}_#{user.last_name}"
		report_path = "C:\\Users\\jesus\\Desktop\\Pasantia\\Proyecto\\bancaplus-postventa\\BM-CM\\nodes_reports\\#{report_name}"
		
		
		body = request.body.read.to_s
		f = File.new(report_path, "w+")
		f.write(body)
		f.close

		# r = Report.new
		# r.file_path = report_path
		# r.name = report_name
		# r.body = parse_report(request.body.read)
		#Push the report into the database
		node.reports.create( { :file_path => report_path, :name => report_name, :body => parse_report(body) })
	end

private
	
	def parse_report(yaml_string)

		lines = (yaml_string.lines).to_a

		result = lines.map do |e|
					e = e.gsub(/(!ruby\/object[\w\d:.]*)/, '')
				end

		return YAML.load(result.join)
	end	

end
