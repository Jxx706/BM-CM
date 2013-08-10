class NodesController < ApplicationController

	
  skip_before_filter :verify_authenticity_token, :only => [:create, :vinculate]	
  def new
  	@title = "Nuevo nodo"
  	@node = Node.new
  end

  def create
  	@node = current_user.nodes.build(params[:node])

  	if @node.save then
  		redirect_to @node
  	else
  		render :new
  	end
  end

  def index
  	@nodes = current_user.nodes
    @title = "Todos los nodos"
  end

  #List all flows associated to this node.
  def index_flows
    @node = current_user.nodes.find(params[:id])
    @title = "Flujos del nodo #{@node.fqdn}"
  end

  def show
  	@node = current_user.nodes.find(params[:id])
  	@title = @node.fqdn
  end

  def home
  	@title = "Nodos"
  end

  def vinculate 
    @node = current_user.nodes.find(params[:node_id])

    unless params[:flows_to_vinculate].nil? || params[:flows_to_vinculate].empty? then
      params[:flows_to_vinculate].each do |flow_name|
        f = current_user.flows.find_by_name(flow_name)
        @node.flows << f
      end
    end

    if @node.save! then
      redirect_to @node
    else
      render 'home'
    end

  end

  #Downloads the file containing all the configurations made by the
  #flows associated to this node.
  def download_conf
    @node = current_user.nodes.find(params[:id])
    file_content = "node '#{@node.fqdn}' {"

    @node.flows.each do |f| 
      file_content << f.body << "\n"
    end

    file_content << "}"
    file_name = current_user.directory_path << "\\nodes.pp"
    file = File.new(file_name, "w+")
    file.puts(file_content)
    file.close

    send_file(file_name)

    # file_name.clear
    # file_name = current_user.directory_path << "\\site.pp"
    # file = File.new(file_name, "w+")
    # file.puts("import 'nodes.pp'")
    # file.close 

    # send_file(file_name)
  end


  #Shows all the reports, discriminated by node.
  def index_nodes_and_reports
    @nodes = current_user.nodes
    @title = "Nodos y reportes"
  end

  def destroy
  	@node = current_user.nodes.find(params[:id])

  	if @node.destroy then
      @nodes = current_user.nodes
  		render :index
  	else
  		redirect_to :home
  	end
  end
end
