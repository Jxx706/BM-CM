class FlowsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  def home #(flows_home_path)
    @title = "Flujos"
  end
  
  #It shows all flows
  #(flows -- GET /flows)
  def index
    @title = "Todos los flujos"
    @flows = current_user.flows
  end

  #It shows just one flow (flow -- GET /flow/:id)
  def show
    @flow = current_user.flows.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It creates a new flow and save it in the database
  #(POST /flows)
  def create

    #params[:attr]

    flow_name = current_user.directory_path << "\\#{params[:flow][:name]}.pp"
    file = File.new(flow_name, "w+")

    case params[:radio_button][:type]
    when "install"
      case params[:select_tool]
      when "mysql"
        if params[:checkbox_mysql_client] == "yes" then
            file.puts(write_class("mysql"))
        end

        attr_hash = {}
        if (params[:attr].delete_if { |k, v| v.empty? || v.nil? }).include?("package_ensure") then
          attr_hash["package_ensure"] = params[:attr][:package_ensure]
          params[:attr].delete(:package_ensure)
        end

        attr_hash["config_hash"] = params[:attr]

        file.reopen(flow_name, "a+")
        file.puts(write_class("mysql::server", attr_hash))
      when "tomcat"
      when "couchbase"
      end
    when "maintenance"
      #handle maintenance. Analogue 
    end

    params[:flow][:file_path] = flow_name
    @flow = current_user.flows.build(params[:flow])

    if @flow.save
      flash[:success] = "Flujo creado"
      redirect_to @flow
    else
      @title = "Nuevo flujo"
      render 'new'
    end
  end

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
  end

  #It saves changes to one flow in the database
  def update #(PUT /flows/:id)
    @flow = current_user.flows.find(params[:id])

    if @flow.update_attributes(params[:flow])
      flash[:success] = "Flujo actualizado con exito."
      redirect_to @flow
    else
      @title = "Editar flujo."
      render 'edit' #Comes back to the edit page 
    end
  end

  #It edits the info of a flow
  def edit #(edit_flow -- GET /flows/:id/edit)
    @title = "Editar flujo"
    @flow = current_user.flows.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It destroys one flow (i.e. removes it from the database)
  #(DELETE /flows/:id)
  def destroy
    @flow = current_user.flows.find(params[:id])
    @flow.destroy
    flash[:success] = "Flujo destruido con exito."

    redirect_to flows_path #Indexes all of the flows again.
  end

  #Download this file.
  def download_file
    nil
  end

  private
    #Given a hash filled with the attributes of the resource and 
    #the resource name, it generates a well defined resource with 
    #the proper syntax corresponding to the Puppet DDL.
    #Example:
    # package{ 'mysql':
    #    ensure => installed,
    # }
    def write_resource(resource_name, title, attributes = {})
      resource = "#{resource_name} {'#{title}':" 
      attributes.each do |key, value|
        resource += "\n\t#{key} => #{value},"
      end
      resource += "}"
    end

    def write_node(node_name, classes = [])
      node = "node '#{node_name}' {"
      classes.each do |c| 
        node += "\n\tinclude #{c}"
      end
      node += "}"
    end

    #Used to write custom clases provided by third party modules
    def write_class(class_name, attributes = {})
      class_resource = "class {'#{class_name}':"
      attributes.each do |key, value|
        class_resource += "\n\t#{key} => #{value},"
      end
      class_resource += "}"
    end
end