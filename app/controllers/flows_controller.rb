class FlowsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create, :vinculate]

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
  #Steps:
  # 1: Flow name and node name.
  # 2: Node type and tool selection.
  # 3: MySQL.
  # 4: Couchbase.
  # 5: Tomcat
  # 6: Maintenance
  def create
    @args = {:current_step => nil, :flow_id => nil}
    case params[:current_step]
      #Flow name and node
      when "1"
        #params[:flow][:file_path] =  current_user.directory_path << (params[:flow][:node_name].empty? ? "\\#{params[:flow][:name]}.pp" : "\\#{params[:flow][:node_name]}\\#{params[:flow][:name]}.pp")
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = String.new
        @flow = current_user.flows.build(params[:flow])

        #If the node name has been provided, then create the corresponding association.
        unless params[:flow][:node_name].empty? then
          @flow.nodes << current_user.nodes.find_by_fqdn(params[:flow][:node_name])
        end

        if @flow.save! then      
          @args[:current_step] = 2 #This is the next step.
          @args[:flow_id] = @flow.id
        else 
          @args[:current_step] = 1
        end

        render :new
      #Flow type
      when "2"
        @flow = current_user.flows.find(params[:flow_id]) #Let's keep adding info to this flow

        params[:flow] = Hash.new
        params[:flow][:hash_attributes] = Hash.new
        case params[:radio_button][:type]
          when "install"
            params[:flow][:hash_attributes][:type] = "install"
            case params[:select_tool]
              when "mysql"
                params[:flow][:hash_attributes][:tool] = "mysql"
                @args[:current_step] = 3
              when "couchbase"
                params[:flow][:hash_attributes][:tool] = "couchbase"
                @args[:current_step] = 4
              when "tomcat"
                params[:flow][:hash_attributes][:tool] = "tomcat"
                @args[:current_step] = 5
            end
          when "maintenance"
            params[:flow][:hash_attributes][:type] = "maintenance"
            @args[:current_step] = 6
        end
        
        if @flow.update_attributes(params[:flow]) then
          @args[:flow_id] = @flow.id
        else
          @args[:current_step] = 2
        end

        render :new
      else
        @flow = current_user.flows.find(params[:flow_id])

        params[:flow] = Hash.new
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"
        #file = File.new(@flow.file_path, "w+")

        case params[:current_step] 
          #Install - MySQL
          when "3"
            if params[:checkbox_mysql_client] == "yes" then
              params[:flow][:body] << write_class("mysql") << "\n\n"
              params[:flow][:hash_attributes]["client"] = true
            else
              params[:flow][:hash_attributes]["client"] = false
            end

            params[:attr].each do |k,v|
              if v.empty? || v.nil? then
                params[:flow][:hash_attributes][k] = Flow.defaults("mysql")[k]
                params[:attr].delete(k)
              
              else
                params[:flow][:hash_attributes][k] = v
              end
            end

            #file.reopen(@flow.file_path, "a+")
            server_hash = Hash.new
            server_hash["package_ensure"] = params[:attr][:package_ensure]

            unless params[:attr].except(:package_ensure).empty? then
              server_hash["config_hash"] = params[:attr].except(:package_ensure)
            end

            params[:flow][:body] << write_class("mysql::server", server_hash)
            #file.close

            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])

            if @flow.update_attributes(params[:flow]) then
              redirect_to @flow
            else
              render :new
            end
          #Install - Couchbase
          when "4"
            params[:attr].each do |k, v| 
              if v.empty? || v.nil? then
                params[:flow][:hash_attributes][k] = Flow.defaults("couchbase")[k]
                params[:attr].delete(k)
              else
                params[:flow][:hash_attributes][k] = v
              end
            end

            params[:flow][:body] << write_class("couchbase", params[:attr])
            #file.close

            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            if @flow.update_attributes(params[:flow]) then
              redirect_to @flow
            else
              render :new
            end
          #Install - Tomcat
          when "5"
            params[:attr].each do |k, v| 
              if v.empty? || v.nil? then
                params[:flow][:hash_attributes][k] = Flow.defaults("tomcat")[k]
                params[:attr].delete(k)
              else
                params[:flow][:hash_attributes][k] = v
              end
            end

            params[:flow][:body] << write_class("tomcat", params[:attr]) << "\n\n"
            #file.close

            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            if @flow.update_attributes(params[:flow]) then
              redirect_to @flow
            else
              render :new
            end
          #Maintenance
          when "6"
            
            #Retrieve the current user
            @flow = current_user.flows.find(params[:flow_id])

            #Create the hash that will contain the updated info.
            params[:flow] = Hash.new
            params[:flow][:hash_attributes] = Hash.new
            params[:flow][:body] = "\n\n"

            #Reopen the file with writing privileges
            #file = File.new(@flow.file_path, "w+")

            #Check if there's any maintenance to do with MySQL
            if params[:mysql_active] == "yes" then

              #Create the hash that will contain the info about the database instance
              params[:flow][:hash_attributes][:db] = Hash.new

              #Remember that these params are mandatory:
              #  - User
              #  - Title
              #  - Password
              params[:attr][:db].each do |k, v| #k stands for "key" and v for "value"
                if v.empty? || v.nil? then #If there's no value, use default (and erase the key associated to it)
                  params[:flow][:hash_attributes][:db][k] = Flow.defaults("mysql")["db"][k]
                  params[:attr][:db].delete(k)
                else #Otherwise, use the value provided.
                  params[:flow][:hash_attributes][:db][k] = v
                end
              end

              #Write to file
              params[:flow][:body] << write_resource('mysql::db', params[:attr][:db].delete("title"), params[:attr][:db]) << "\n\n"

              #If the user wants a backup...
              if params[:backup] == "yes" then

                #Create the hash that will contain all the backup info
                params[:flow][:hash_attributes][:db_backup] = Hash.new
                
                #Copy one hash into other
                #Remember that these params are mandatory:
                #  - Backupuser
                #  - Backuppassword
                #  - Backupdir
                params[:attr][:db_backup].each do |k, v| 
                  params[:flow][:hash_attributes][:db_backup][k] = v
                end

                #Write to file again
                params[:flow][:body] << write_class('mysql::backup', params[:attr][:db_backup]) << "\n\n"
              end

              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #Check if there's any maintenance to do with Couchbase
            if params[:couchbase_active] == "yes" then
              #Create the hash that will contain the info about the bucket
              params[:flow][:hash_attributes][:bucket] = Hash.new

              #Remember that these params are mandatory:
              #  - Title
              params[:attr][:bucket].each do |k, v| 
                if v.empty? || v.nil? then 
                  params[:flow][:hash_attributes][:bucket][k] = Flow.defaults("couchbase")["bucket"][k]
                  params[:attr][:bucket].delete(k)
                else
                  params[:flow][:hash_attributes][:bucket][k] = v
                end
              end

              params[:flow][:body] << write_resource("couchbase::bucket", params[:attr][:bucket].delete("title"), params[:attr][:bucket]) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end            

            #Check if there's any maintenance to do with Tomcat
            if params[:tomcat_active] == "yes" then
              #Create the hash that will contain the info about the instance
              params[:flow][:hash_attributes][:instance] = Hash.new

              #Remember that these params are mandatory:
              #  - Name
              params[:attr][:instance].each do |k, v| 
                if v.empty? || v.nil? then 
                  params[:flow][:hash_attributes][:instance][k] = Flow.defaults("tomcat")["instance"][k]
                  params[:attr][:instance].delete(k)
                else
                  params[:flow][:hash_attributes][:instance][k] = v
                end
              end

              params[:flow][:body] << write_resource("tomcat::instance", params[:attr][:instance].delete("name"), params[:attr][:instance]) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #There's nothing left to do
            #file.close

            #Update
            if @flow.update_attributes(params[:flow]) then #On success
              redirect_to @flow
            else #On failure
              render :new
            end
        end
    end
  end

  # def create
  #   flow_name = current_user.directory_path << "\\#{params[:flow][:name]}.pp"
  #   params[:flow][:hash_attributes] = Hash.new
  #   file = File.new(flow_name, "w+")

  #   case params[:radio_button][:type]
  #     when "install"
        
  #       params[:flow][:hash_attributes]["type"] = "install"
        
  #       case params[:select_tool]
  #         when "mysql"
  #           params[:flow][:hash_attributes]["tool"] = "mysql"
  #           if params[:checkbox_mysql_client] == "yes" then
  #               file.puts(write_class("mysql"))
  #               params[:flow][:hash_attributes]["client"] = true
  #           else
  #             params[:flow][:hash_attributes]["client"] = false
  #           end

  #           params[:attr].each do |k,v|
  #             if v.empty? || v.nil? then
  #               params[:flow][:hash_attributes][k] = Flow.defaults("mysql")[k]
  #               params[:attr].delete(k)
  #             else
  #               params[:flow][:hash_attributes][k] = v
  #             end
  #           end

  #           file.reopen(flow_name, "a+")
  #           file.puts(write_class("mysql::server", {"package_ensure" => params[:attr][:package_ensure], 
  #                                                   "config_hash" => params[:attr].delete(:package_ensure)
  #                                                   }))
          
  #         when "tomcat"
          
  #         when "couchbase"
  #           params[:flow][:hash_attributes]["tool"] = "couchbase"

  #           params[:attr].each do |k, v| 
  #             if v.empty? || v.nil? then
  #               params[:flow][:hash_attributes][k] = Flow.defaults("couchbase")[k]
  #               params[:attr].delete(k)
  #             else
  #               params[:flow][:hash_attributes][k] = v
  #             end
  #           end

  #           file.puts(write_class("couchbase", params[:attr]))
  #       end
  #     when "maintenance"
  #       #handle maintenance. Analogue 
  #   end

  #   params[:flow][:file_path] = flow_name
  #   @flow = current_user.flows.build(params[:flow])
      
  #   if @flow.save
  #     flash[:success] = "Flujo creado"
  #     redirect_to @flow
  #   else
  #     @title = "Nuevo flujo"
  #     render 'new'
  #   end
  #end

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
    @args = {:current_step => 1, :flow_id => nil}
  end

  #It saves changes to one flow in the database
  def update #(PUT /flows/:id)
    @flow = current_user.flows.find(params[:id])

    #file = File.new(@flow.file_path, "w+")
    case @flow.hash_attributes["type"]
      when "install"
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"

        params[:config_hash].each do |k, v|
          params[:flow][:hash_attributes][k] = v
        end

        params[:flow][:hash_attributes]["package_ensure"] = params[:package_ensure]

        if params[:checkbox_mysql_client] == "yes" then
          params[:flow][:hash_attributes]["client"] = true
          params[:flow][:body] << write_class("mysql")
        else
          params[:flow][:hash_attributes]["client"] = false
        end

        params[:flow][:hash_attributes]["type"] = "install"
        params[:flow][:hash_attributes]["tool"] = "mysql"
        #file.reopen(@flow.file_path, "a+")
        params[:flow][:body] << write_class("mysql::server", {"package_ensure" => params[:package_ensure], "config_hash" => params[:config_hash]})

      when "maintenance"
        #Nothing so far
    end

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

  def vinculate 
    @flow = current_user.flows.find(params[:flow_id])

    unless params[:nodes_to_vinculate].nil? || params[:nodes_to_vinculate].empty? then
      params[:nodes_to_vinculate].each do |node_fqdn|
        n = current_user.flows.find_by_name(node_fqdn)
        @flow.nodes << n
      end
    end

    if @flow.save! then
      redirect_to @flow
    else
      render 'home'
    end
    
  end

  #It destroys one flow (i.e. removes it from the database)
  #(DELETE /flows/:id)
  def destroy
    @flow = current_user.flows.find(params[:id])
    #File.delete(@flow.file_path)
    @flow.destroy
    flash[:success] = "Flujo destruido con exito."

    redirect_to flows_path #Indexes all of the flows again.
  end

  #Download this file.
  #def download
    #@flow = current_user.flows.find(params[:id])
    #send_file(@flow.file_path)
  #end

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