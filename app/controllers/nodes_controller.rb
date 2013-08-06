class NodesController < ApplicationController

	
  skip_before_filter :verify_authenticity_token, :only => [:create]	
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
  end

  def show
  	@node = current_user.nodes.find(params[:id])
  	@title = @node.fqdn
  end

  def home
  	@title = "Nodos"
  end

  #Shows all the reports, discriminated by node.
  def index_nodes_and_reports
    @node = current_user.nodes
  end

  def destroy
  	@node = current_user.nodes.find(params[:id])

  	if @node.destroy then
  		render :home
  	else
  		redirect_to @node
  	end
  end
end
