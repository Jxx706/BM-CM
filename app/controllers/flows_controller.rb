#encoding: utf-8

class FlowsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create, :handle_nodes]

######################################################################
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

######################################################################
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

        #Remove the array of nodes from params, and take those elements which are empty and asign them
        #to the variable 'nodes'.
        nodes = params[:flow][:nodes].nil? ? nil : (params[:flow].delete(:nodes)).delete_if { |e| e.blank? || e.nil? } 
        @flow = current_user.flows.build(params[:flow])

        #If the nodes names have been provided, then create the corresponding association.
        unless nodes.nil? || nodes.empty?  then
          nodes.each do |n| 
            @flow.nodes << current_user.nodes.find_by_fqdn(n)
          end
        end

        if @flow.save then      
          @args[:current_step] = 2 #This is the next step.
          @args[:flow_id] = @flow.id
        else 
          @args[:current_step] = 1
        end

        render :action => :new, :locals => { :flow => @flow }
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
          when "miscellaneous"
            @args[:current_step] = 7
        end
        
        if @flow.update_attributes(params[:flow]) then
          @args[:flow_id] = @flow.id
        else
          @args[:current_step] = 2
        end

        render :action => :new, :locals => { :flow => @flow }
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
              @args[:flow_id] = @flow.id
              @args[:current_step] = 3
              @flow.hash_attributes.clear
              render :action => :new, :locals => { :flow => @flow }
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
              @args[:flow_id] = @flow.id
              @args[:current_step] = 4
              @flow.hash_attributes.clear
              render :action => :new, :locals => { :flow => @flow }
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
              @args[:flow_id] = @flow.id
              @args[:current_step] = 5
              @flow.hash_attributes.clear
              render :action => :new, :locals => { :flow => @flow }
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


            #Update
            if @flow.update_attributes(params[:flow]) then #On success
              redirect_to @flow
            else #On failure
              @args[:current_step] = 6
              @args[:flow_id] = @flow.id
              @flow.hash_attributes.clear
              render :action => :new, :locals => { :flow => @flow }
            end

          #Miscellaneous 
          when "7"
            #Retrieve the current user
            @flow = current_user.flows.find(params[:flow_id])

            #Create the hash that will contain the updated info.
            params[:flow] = Hash.new
            params[:flow][:hash_attributes] = Hash.new
            params[:flow][:body] = "\n\n"

            #Check if there's a file to be created or deleted
            #Params:
            #   - All mandatory
            if params[:create_delete_file_active] == "yes" then
              params[:flow][:hash_attributes][:cdf] = params[:attr][:cdf].clone
              quote_hash(params[:attr][:cdf]) #Quote it so it will work with Puppet
              params[:flow][:body] << write_resource("file", params[:attr][:cdf]["name"], params[:attr][:cdf].except("name")) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #Check if there is new content for a specific file
            #Params:
            #   - All mandatory
            if params[:change_content_of_file_active] == "yes" then
              params[:flow][:hash_attributes][:ccof] = params[:attr][:ccof].clone
              quote_hash(params[:attr][:ccof])
              params[:flow][:body] << write_resource("file", params[:attr][:ccof]["name"], params[:attr][:ccof].except("name")) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #Check if there's a line to be appended or removed from a file
            #Params:
            #   - All mandatory
            if params[:add_remove_line_from_file_active] == "yes" then
              params[:flow][:hash_attributes][:arlff] = params[:attr][:arlff].clone
              quote_hash(params[:attr][:arlff])
              #Theres a dependency that has to be satisfied
              params[:flow][:body] << write_resource("file", params[:attr][:arlff]["path"], {"ensure" => "present"}) << " -> "
              params[:flow][:body] << "\n" << write_resource("file_line", "line_#{rand(99999).to_s}", params[:attr][:arlff]) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #Check if there's a file to be copied
            if params[:copy_file_active] == "yes" then
              params[:flow][:hash_attributes][:cf] = params[:attr][:cf].clone
              quote_hash(params[:attr][:cf])
              params[:flow][:body] << write_resource("file", params[:attr][:cf]["name"], params[:attr][:cf].except("name")) << "\n\n"
              params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
            end

            #Finally, let's update this thing
            if @flow.update_attributes(params[:flow]) then #On success
              redirect_to @flow
            else #On failure
              @args[:current_step] = 7
              @args[:flow_id] = @flow.id
              @flow.hash_attributes.clear
              render :action => :new, :locals => { :flow => @flow }
            end
        end
    end
  end

######################################################################

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
    @args = {:current_step => 1, :flow_id => nil}
    render :action => :new, :locals => { :flow => nil }
  end

######################################################################
  #It saves changes to one flow in the database
  #The overall behavior goes like this:
  #  --> Check the kind of the flow:
  #    --> If install: Easy; just keep the values which 
  #                    aren't blank or nil and mix them with
  #                    the values given to the flow when created.
  #                    Then re-write the body.
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

            #First check if MySQL Client must be installed
            if params[:checkbox_mysql_client] == "yes" then
              params[:flow][:body] << write_class("mysql") << "\n\n"
              params[:flow][:hash_attributes]["client"] = true
            else
              params[:flow][:hash_attributes]["client"] = false
            end

            #Mix the old and the new values and store them in the corresponding hash 
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr].delete_if { |key, value| value.blank? || value.nil? })

            #This hash is used only for the parametters related with the MySQL Server.
            server_hash = Hash.new
            #Remove the version from the params hash, and store it
            server_hash["package_ensure"] = params[:attr].delete(:package_ensure)

            #If the only attribute specified by the user was the server version,
            #then ain't no need to write a config_hash
            unless params[:attr].empty? then
              server_hash["config_hash"] = params[:attr]
            end

            #Lastly, write the body
            params[:flow][:body] << write_class("mysql::server", server_hash)

          when "couchbase"
            #Replace old values with the new ones that aren't nil nor blank.
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr].delete_if { |key, value| value.blank? || value.nil? })
            #Re-writte the body of the flow.
            params[:flow][:body] << write_class("couchbase", params[:flow][:hash_attributes])
          when "tomcat"
            
            #If the version is not specified, then install the most recent provided by
            #the default package manager of the OS.
            if params[:attr][:version].nil? || params[:attr][:version].empty? then 
              params[:flow][:body] << "include tomcat"
            #Otherwise, if the version was provided, then a mirror MUST have been provided as well!
            else
              params[:flow][:body] << "$tomcat::mirror = \"#{params[:attr][:mirror]}\"\n$tomcat::version = \"#{params[:attr][:version]}\"\ninclude tomcat::source"
            end
            
            #Replace old values with the new ones.
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:attr])
        end
        
      #This is the tricky part
      when "maintenance"

        ########################################################################################################
        # KEEP THIS IN MIND: Mix old values with new. BUT if there's a tool configuration                      #
        # that wasn't set up in the beginning, we must handle like if a new config (instead of a modification) #
        ########################################################################################################

        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"


        #Remove unselected configurations
        if params[:mysql_active] == "no" then
          @flow.hash_attributes.delete(:db)
          @flow.hash_attributes.delete(:db_backup)
        end

        if params[:couchbase_active] == "no" then
          @flow.hash_attributes.delete(:bucket)
        end

        if params[:tomcat_active] == "no" then
          @flow.hash_attributes.delete(:instance)
        end

        #Handle MYSQL Update
        if params[:mysql_active] == "yes" then
          params[:flow][:hash_attributes][:db] = Hash.new

          #If there are previous values, then mix
          if @flow.hash_attributes.has_key?(:db) then
            params[:flow][:hash_attributes][:db] = @flow.hash_attributes[:db].merge(
              params[:attr][:db].delete_if do |key, value| 
                value.blank? || value.nil?
              end
            )
          else
            #if there wasn't configurations for mysql, then handle like it's new
            params[:attr][:db].each do |k, v| #k stands for "key" and v for "value"
              if v.empty? || v.blank? || v.nil? then #If there's no value, use default (and erase the key associated to it)
                params[:flow][:hash_attributes][:db][k] = Flow.defaults("mysql")["db"][k]
                params[:attr][:db].delete(k)
              else #Otherwise, use the value provided.
                params[:flow][:hash_attributes][:db][k] = v
              end
            end
          end

          #This line is crucial: It mixes ALL the OLD parameters with the new
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])

          params[:flow][:body] << write_resource(
            'mysql::db', #Name of the resource 
            params[:flow][:hash_attributes][:db]["title"], #mysql::db {'<title>': ... }
            params[:flow][:hash_attributes][:db].except("title") #The attributes without title
            ) << "\n\n" 
          

          #If the user wants a backup 
          if params[:backup] == "yes" then

            params[:flow][:hash_attributes][:db_backup] = Hash.new

            #Check if there are previous values for backup
            if @flow.hash_attributes.has_key?(:db_backup) then
              params[:flow][:hash_attributes][:db_backup] = @flow.hash_attributes[:db_backup].merge(params[:attr][:db_backup].delete_if {|key, value| value.blank? || value.nil?})            
            #Handle like it's new
            else
              params[:flow][:hash_attributes][:db_backup] = params[:attr][:db_backup]
            end

            #This line is crucial: It mixes ALL the OLD parameters with the new
            params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])

            params[:flow][:body] << write_class('mysql::backup', params[:flow][:hash_attributes][:db_backup]) << "\n\n"
          else
            @flow.hash_attributes.delete(:db_backup)
          end
        end

        # Handle COUCHBASE Update
        if params[:couchbase_active] == "yes" then

          params[:flow][:hash_attributes][:bucket] = Hash.new

          #If there was previous values
          if @flow.hash_attributes.has_key?(:bucket) then
            params[:flow][:hash_attributes][:bucket] = @flow.hash_attributes[:bucket].merge(params[:attr][:bucket].delete_if {|key, value| value.blank? || value.nil?})
          #Handle like it's new
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

          params[:flow][:body] << write_resource(
            "couchbase::bucket", #resource type
            params[:flow][:hash_attributes][:bucket]["title"], #couchbase::bucket {'<title>': ...}
            params[:flow][:hash_attributes][:bucket].except("title") #attributes except title
            ) << "\n\n"

          #This line is crucial: It mixes ALL the OLD parameters with the new
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end

        # Handle TOMCAT Update
        if params[:tomcat_active] == "yes" then

          params[:flow][:hash_attributes][:instance] = Hash.new
          #Mix the old with the new
          if @flow.hash_attributes.has_key?(:instance) then
            params[:flow][:hash_attributes][:instance] = @flow.hash_attributes[:instance].merge(params[:attr][:instance].delete_if {|key, value| value.blank? || value.nil?})

          #Handle like it's new
          else
             params[:attr][:instance].each do |k, v| 
                if v.empty? || v.nil? then 
                  params[:flow][:hash_attributes][:instance][k] = Flow.defaults("tomcat")["instance"][k]
                  params[:attr][:instance].delete(k)
                else
                  params[:flow][:hash_attributes][:instance][k] = v
                end
              end

              params[:flow][:body] << write_resource(
                "tomcat::instance", #resource type
                params[:flow][:hash_attributes][:instance]["name"], #tomcat::instance {'<name>': ... }
                params[:flow][:hash_attributes][:instance].except("name") #attributes except name
                ) << "\n\n"
          end

          #This line is crucial: It mixes ALL the OLD parameters with the new
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end
      when "miscellaneous"
        params[:flow][:hash_attributes] = Hash.new
        params[:flow][:body] = "\n\n"

        #Remove unselected configurations
        if params[:create_delete_file_active] == "no" then
          @flow.hash_attributes.delete(:cdf)
        end

        if params[:change_content_of_file_active] == "no" then
          @flow.hash_attributes.delete(:ccof)
        end

        if params[:add_remove_line_from_file_active] == "no" then
          @flow.hash_attributes.delete(:arlff)
        end

        if params[:copy_file_active] == "no" then
          @flow.hash_attributes.delete(:cf)
        end


        #Handle CREATE/DELETE updates
        if params[:create_delete_file_active] == "yes" then
          
          params[:flow][:hash_attributes][:cdf] = Hash.new
          #If there are previous values, then mix
  
          quote_hash(params[:attr][:cdf]) #Quote it so it will work with Puppet

          if @flow.hash_attributes.has_key?(:cdf) then
            params[:flow][:hash_attributes][:cdf] = @flow.hash_attributes[:cdf].merge(
              params[:attr][:cdf].delete_if {
                |key, value| value.blank? || value.nil?
                }
              )
          end

          params[:flow][:body] << write_resource("file", 
            params[:flow][:hash_attributes][:cdf]["name"],
            params[:flow][:hash_attributes][:cdf].except("name")) << "\n\n"
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end

        #Handle CHANGE CONTENT updates
        if params[:change_content_of_file_active] == "yes" then
          
          params[:flow][:hash_attributes][:ccof] = Hash.new
          quote_hash(params[:attr][:ccof])
          #If there are previous values, then mix
          if @flow.hash_attributes.has_key?(:ccof) then
            params[:flow][:hash_attributes][:ccof] = @flow.hash_attributes[:ccof].merge(
              params[:attr][:ccof].delete_if {
                |key, value| value.blank? || value.nil?
              }
            )
          else #Otherwise, handle like it's new
            params[:flow][:hash_attributes][:ccof] = params[:attr][:ccof].clone
          end

          params[:flow][:body] << write_resource("file", 
            params[:flow][:hash_attributes][:ccof]["name"], 
            params[:flow][:hash_attributes][:ccof].except("name")) << "\n\n"
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end

        #Handle ADD/REMOVE LINE updates
        if params[:add_remove_line_from_file_active] == "yes" then
          
          params[:flow][:hash_attributes][:arlff] = Hash.new

          quote_hash(params[:attr][:arlff])

          #If there are previous values, then mix
          if @flow.hash_attributes.has_key?(:arlff) then
            params[:flow][:hash_attributes][:arlff] = @flow.hash_attributes[:arlff].merge(
              params[:attr][:arlff].delete_if {
                |key, value| value.blank? || value.nil?
              }
            )
          else #Otherwise, handle like it's new
            params[:flow][:hash_attributes][:arlff] = params[:attr][:arlff].clone
          end

          #Theres a dependency that has to be satisfied
          params[:flow][:body] << write_resource("file", 
            params[:flow][:hash_attributes][:arlff]["path"], 
            {"ensure" => "present"}) << " -> "
          params[:flow][:body] << "\n" << write_resource("file_line", 
            "line_#{rand(99999).to_s}", 
            params[:flow][:hash_attributes][:arlff]) << "\n\n"
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end

        #Handle COPY updates
        if params[:copy_file_active] == "yes" then
          
          params[:flow][:hash_attributes][:cf] = Hash.new

          quote_hash(params[:attr][:cf])

          #If there are previous values, then mix
          if @flow.hash_attributes.has_key?(:cf) then
            params[:flow][:hash_attributes][:cf] = @flow.hash_attributes[:cf].merge(
              params[:attr][:cf].delete_if {
                |key, value| value.blank? || value.nil?
              }
            )
          else #Otherwise, handle like it's new
            params[:flow][:hash_attributes][:cf] = params[:attr][:cf].clone
          end

          params[:flow][:body] << write_resource("file", 
            params[:flow][:hash_attributes][:cf]["name"], 
            params[:flow][:hash_attributes][:cf].except("name")) << "\n\n"
          params[:flow][:hash_attributes] = @flow.hash_attributes.merge(params[:flow][:hash_attributes])
        end
    end

      #Associate with the specified nodes
    unless params[:nodes_to_attach].nil? || params[:nodes_to_attach].empty?  then
      params[:nodes_to_attach].each do |node_fqdn|
        n = current_user.nodes.find_by_fqdn(node_fqdn)
        @flow.nodes << n
      end
    end

    old_hash = @flow.hash_attributes #Just in case the record doesn't save 

    if @flow.update_attributes(params[:flow])
      flash[:success] = "Flujo actualizado con exito."
      redirect_to @flow
    else
      @title = "Editar flujo."
      @flow.hash_attributes = old_hash #Since it didn't save, then retake the old values
      render :action => :edit, :locals => { :flow => @flow } #Comes back to the edit page 
    end
  end

######################################################################
  #It edits the info of a flow
  def edit #(edit_flow -- GET /flows/:id/edit)
    @title = "Editar flujo"
    @flow = current_user.flows.find(params[:id]) #Retrieves the info of the flow instance with id = :id
    render :action => :edit, :locals => { :flow => nil }
  end

######################################################################

  def handle_nodes
    @flow = current_user.flows.find(params[:flow_id])

    unless params[:nodes_to_attach].nil? || params[:nodes_to_attach].empty? then
      nodes_to_attach = current_user.nodes.select { |n| params[:nodes_to_attach].include?(n.fqdn) }
        @flow.nodes << nodes_to_attach
    end

    unless params[:nodes_to_deattach].nil? || params[:nodes_to_deattach].empty? then
        nodes_to_deattach = current_user.nodes.select { |n| params[:nodes_to_deattach].include?(n.fqdn) }
        @flow.nodes.destroy(nodes_to_deattach)
    end

    if @flow.save! then
      redirect_to @flow
    else
      render 'home'
    end
    
  end

######################################################################
  #It destroys one flow (i.e. removes it from the database)
  #(DELETE /flows/:id)
  def destroy
    @flow = current_user.flows.find(params[:id])
    #File.delete(@flow.file_path)
    @flow.destroy
    flash[:success] = "Flujo destruido con exito."

    redirect_to flows_path #Indexes all of the flows again.
  end

######################################################################
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
      title = "\"#{title}\"" unless (title[0] == '"' && title[-1] == '"')
      resource = "#{resource_name} {#{title}:" 
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

    #Make it smart:
    def quote_hash(hash)
      out = Hash.new
      hash.each do |k, v|
        if !v.blank? && v.class == String then
          hash[k] = "\"#{v}\""
        end
      end
    end
end