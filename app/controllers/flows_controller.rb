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
        nodes = params[:flow].delete(:nodes)
        @flow = current_user.flows.build(params[:flow])

        #If the nodes names have been provided, then create the corresponding association.
        unless nodes.nil? || nodes.empty? then
          nodes.each do |n| 
            @flow.nodes << current_user.nodes.find_by_fqdn(n)
          end
        end

        if @flow.save! then      
          @args[:current_step] = 2 #This is the next step.
          @args[:flow_id] = @flow.id
        else 
          @args[:current_step] = 1
        end

        render :new
      #Flow kind
      when "2"
        @flow = current_user.flows.find(params[:flow_id]) #Let's keep adding info to this flow

        params[:flow] = Hash.new
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:kind] = params[:flow_kind]
        
        case params[:flow][:kind]
          when "install"
            #params[:flow][:hash_attributes][:kind] = "install"
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
            #params[:flow][:hash_attributes][:kind] = "maintenance"
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

            if params[:attr][:version].nil? || params[:attr][:version].empty? then 
              params[:flow][:body] << "include tomcat"
            else
              params[:flow][:body] << "$tomcat::mirror = \"#{params[:attr][:mirror]}\"\n$tomcat::version = \"#{params[:attr][:version]}\"\ninclude tomcat::source"
            end
            
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr])
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

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
    @args = {:current_step => 1, :flow_id => nil}
  end

  #It saves changes to one flow in the database
  #THIS LINE IS IMPORTANT! new_hash_attributes = @flow.hash_attributes.merge(params[:hash_attributes]) {|k, ov, nv| nv.nil? ? ov : nv}
  def update #(PUT /flows/:id)
    #Retrieve the flow to be edited
    @flow = current_user.flows.find(params[:id])
    params[:flow] = Hash.new

    #Different actions depends on the kind of flow
    case @flow.kind
      when "install"
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"

        case @flow.hash_attributes["tool"]
          when "mysql"

            if params[:checkbox_mysql_client] == "yes" then
              params[:flow][:body] << write_class("mysql") << "\n\n"
              params[:flow][:hash_attributes]["client"] = true
            else
              params[:flow][:hash_attributes]["client"] = false
            end

            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr].delete_if { |key, value| value.blank? || value.nil? })

            server_hash = Hash.new
            server_hash["package_ensure"] = params[:attr].delete(:package_ensure)

            unless params[:attr].empty? then
              server_hash["config_hash"] = params[:attr]
            end

            params[:flow][:body] << write_class("mysql::server", server_hash)

          when "couchbase"
            #Replace old values with the new ones that aren't nil
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr].delete_if { |key, value| value.blank? || value.nil? })
            #Rewritte the body of the flow.
            params[:flow][:body] << write_class("couchbase", params[:flow][:hash_attributes])
          when "tomcat"
            if params[:attr][:version].nil? || params[:attr][:version].empty? then 
              params[:flow][:body] << "include tomcat"
            else
              params[:flow][:body] << "$tomcat::mirror = \"#{params[:attr][:mirror]}\"\n$tomcat::version = \"#{params[:attr][:version]}\"\ninclude tomcat::source"
            end
            
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr])
        end
        
      when "maintenance"
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"

        if params[:mysql_active] == "yes" then
          params[:flow][:hash_attributes][:db] = Hash.new

          if @flow.hash_attributes.has_key?(:db) then
            params[:flow][:hash_attributes][:db] = @flow.hash_attributes[:db].merge(params[:attr][:db].delete_if {|key, value| value.blank? || value.nil?})
          else
            #if there wasn't configurations for mysql, then handle like it's new
            params[:attr][:db].each do |k, v| #k stands for "key" and v for "value"
                if v.empty? || v.nil? then #If there's no value, use default (and erase the key associated to it)
                  params[:flow][:hash_attributes][:db][k] = Flow.defaults("mysql")["db"][k]
                  params[:attr][:db].delete(k)
                else #Otherwise, use the value provided.
                  params[:flow][:hash_attributes][:db][k] = v
                end
              end
          end

          params[:flow][:body] << write_resource('mysql::db', params[:flow][:hash_attributes][:db].except("title"), params[:flow][:hash_attributes][:db]) << "\n\n"
          
          if params[:backup] == "yes" then
            params[:flow][:hash_attributes][:db_backup] = Hash.new
            params[:flow][:hash_attributes][:db_backup] = @flow.hash_attributes[:db_backup].merge(params[:attr][:db_backup].delete_if {|key, value| value.blank? || value.nil?})            
            params[:flow][:body] << write_class('mysql::backup', params[:flow][:hash_attributes][:db_backup]) << "\n\n"
          else
            @flow.hash_attributes.delete(:db_backup)
          end
        end

        if params[:couchbase_active] == "yes" then
          params[:flow][:hash_attributes][:bucket] = Hash.new

          if @flow.hash_attributes.has_key?(:bucket) then
            params[:flow][:hash_attributes][:bucket] = @flow.hash_attributes[:bucket].merge(params[:attr][:bucket].delete_if {|key, value| value.blank? || value.nil?})
          else
            params[:attr][:bucket].each do |k, v| 
                if v.empty? || v.nil? then 
                  params[:flow][:hash_attributes][:bucket][k] = Flow.defaults("couchbase")["bucket"][k]
                  params[:attr][:bucket].delete(k)
                else
                  params[:flow][:hash_attributes][:bucket][k] = v
                end
              end
          end

          params[:flow][:body] << write_resource("couchbase::bucket", params[:flow][:hash_attributes][:bucket].except("title"), params[:flow][:hash_attributes][:bucket]) << "\n\n"
        end

        if params[:tomcat_active] == "yes" then
          params[:flow][:hash_attributes][:instance] = Hash.new
          params[:flow][:hash_attributes][:instance] = @flow.hash_attributes[:instance].merge(params[:attr][:instance].delete_if {|key, value| value.blank? || value.nil?})
        end
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
        n = current_user.nodes.find_by_fqdn(node_fqdn)
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