# == Schema Information
#
# Table name: flows
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  hash_attributes :text
#  body            :string(255)
#  kind            :string(255)
#

class HashAttributesValidator < ActiveModel::EachValidator
  VALID_IP_ADDRESS = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

  def validate_each(record, attribute, value) 
    #value = hash_attributes
    if record.kind == "install" then
      if value["tool"] == "mysql" then
        #Port validations
        unless (1..65535).to_a.include?(value[:port].to_i) then
          record.errors[attribute] << "El puerto debe estar entre 1 y 65535."
        end

        unless value[:port] =~ /^\d+$/ then
          record.errors[attribute] << "El puerto debe ser un entero."
        end

        #Group name
        unless (1..16).to_a.include?(value[:root_group].size) then
          record.errors[attribute] << "Nombre de grupo debe ser de maximo 16 caracteres."
        end

        unless value[:root_group] =~ /^[_a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Nombre de grupo no cumple formato; debe empezar con una letra o _ y continuar solo con letras, - o _"
        end
          
        #Root password
        unless value[:root_password].to_i >= 6 then
          record.errors[attribute] << "Clave demasiado corta. Minimo 6 caracteres."
        end

        #IP address
        unless value[:bind_address] =~ VALID_IP_ADDRESS then
          record.errors[attribute] << "La direccion IP no es valida."
        end

      elsif value["tool"] == "couchbase" then
      
        #User
        unless value[:user] =~ /^[_a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Nombre de usuario no cumple formato; debe empezar con una letra o _ y continuar solo con letras, - o _"
        end

         unless (1..16).to_a.include?(value[:user].size) then
          record.errors[attribute] << "Nombre de usuario debe ser de maximo 16 caracteres."
        end

        #Password
        unless value[:password].to_i >= 6 then
          record.errors[attribute] << "Clave demasiado corta. Minimo 6 caracteres."
        end
      elsif value["tool"] == "tomcat" then
      end          
    elsif record.kind == "maintenance" then

      if value.has_key?(:db) then
        db = value[:db]

        #DB name
        unless !(db[:title].nil? || db[:title].blank?) then
          record.errors[attribute] << "MySQL - El nombre es obligatorio."
        end

        unless db[:title] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "MySQL - Nombre no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

        #User
        unless !(db[:user].nil? || db[:title].blank?) then
          record.errors[attribute] << "MySQL - El nombre de usuario es obligatorio."
        end

        unless db[:user] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "MySQL - Nombre usuario no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

        #Host
        unless db[:host] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "MySQL - Host no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

         #Password
        unless db[:password].to_i >= 6 then
          record.errors[attribute] << "MySQL - Clave demasiado corta. Minimo 6 caracteres."
        end

        unless !(db[:password].nil? || db[:password].blank?) then
          record.errors[attribute] << "MySQL - Clave es obligatoria."
        end

        #Grant
        if db[:grant].nil? then
          record.errors[attribute] << "MySQL - Debe especificar los permisos."
        end

        if !db[:grant].nil? && db[:grant].include?('all') && db[:grant].size > 1 then 
          record.errors[attribute] << "MySQL - Si especifica TODOS, no puede escoger mas opciones."
        end
      end

      if value.has_key?(:db_backup) then
        backup = value(:db_backup)
      end

      if value.has_key?(:bucket) then
        bucket = value[:bucket]

        #Bucket name
        unless !(bucket[:title].nil? || bucket[:title].blank?) then
          record.errors[attribute] << "Couchbase - El nombre es obligatorio."
        end

        unless bucket[:title] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Couchbase - Nombre no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

        #Port validations
        unless (1..65535).to_a.include?(bucket[:port].to_i) then
          record.errors[attribute] << "Couchbase - El puerto debe estar entre 1 y 65535."
        end

        unless bucket[:port] =~ /^\d+$/ then
          record.errors[attribute] << "Couchbase - El puerto debe ser un entero."
        end

        #User
        unless bucket[:user] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Couchbase - Nombre de usuario no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end   

        #Password
        unless bucket[:password].to_i >= 6 then
          record.errors[attribute] << "Couchbase - Clave demasiado corta. Minimo 6 caracteres."
        end
      end

      if value.has_key?(:instance) then
        instance = value[:instance]

        #Bucket name
        unless !(instance[:name].nil? || instance[:name].blank?) then
          record.errors[attribute] << "Tomcat - El nombre es obligatorio."
        end

        unless instance[:name] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Tomcat - Nombre no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

        #Owner
        unless instance[:owner] =~ /^[a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Tomcat - Nombre de propietario no cumple formato; debe empezar con una letra y continuar solo con letras, - o _"
        end

        #Group
        unless instance[:group] =~ /^[_a-z][-0-9_a-z]*$/ then
          record.errors[attribute] << "Tomcat - Nombre de grupo no cumple formato; debe empezar con una letra o _ y continuar solo con letras, - o _"
        end  

        #Puertos
        unless (1..65535).to_a.include?(instance[:server_port].to_i) then
          record.errors[attribute] << "Tomcat - El puerto del servidor debe estar entre 1 y 65535."
        end

        unless instance[:server_port] =~ /^\d+$/ then
          record.errors[attribute] << "Tomcat - El puerto del servidor debe ser un entero."
        end

        unless (1..65535).to_a.include?(instance[:http_port].to_i) then
          record.errors[attribute] << "Tomcat - El puerto HTTP debe estar entre 1 y 65535."
        end

        unless instance[:http_port] =~ /^\d+$/ then
          record.errors[attribute] << "Tomcat - El puerto HTTP debe ser un entero."
        end

         unless (1..65535).to_a.include?(instance[:ajp_port].to_i) then
          record.errors[attribute] << "Tomcat - El puerto AJP debe estar entre 1 y 65535."
        end

        unless instance[:ajp_port] =~ /^\d+$/ then
          record.errors[attribute] << "Tomcat - El puerto AJP debe ser un entero."
        end

        if (instance[:server_port].to_i == instance[:http_port].to_i) || 
          (instance[:server_port].to_i == instance[:ajp_port].to_i) || 
          (instance[:http_port].to_i == instance[:ajp_port].to_i) then
          record.errors[attribute] << "Tomcat - Los puertos deben ser diferentes."
        end
      end
    end
  end
end

class Flow < ActiveRecord::Base

    MYSQL_DEFAULTS = {
        "bind_address"        => '127.0.0.1',
        #{}"manage_service"      => true,
        "package_ensure"      => 'present',
        "port"                => 3306,
        "max_allowed_packet"  => '16M',
        "root_password"       => 'UNSET',
        #"redhat_family"       => { 
            "basedir"               => '/usr',
         #   "client_package_name"   => 'mysql',
          #  "config_file"           => '/etc/my.cnf',
            "datadir"               => '/var/lib/mysql',
            "tmpdir"                => '/tmp',
           # "java_package_name"     => 'mysql-connector-java',
            #"log_error"             => '/var/log/mysqld.log',
           # "php_package_name"      => 'php-mysql',
           # "pidfile"               => '/var/run/mysqld/mysqld.pid',
          #  "python_package_name"   => 'MySQL-python',
           # "root_group"            => 'root',
           # "ruby_package_name"     => 'ruby-mysql',
           # "ruby_package_provider" => 'gem',
           # "service_name"          => 'mysqld',
           # "server_package_name"   => 'mysql-server',
           # "socket"                => '/var/lib/mysql/mysql.sock',
           # "ssl_ca"                => '/etc/mysql/cacert.pem',
           # "ssl_cert"              => '/etc/mysql/server-cert.pem',
           # "ssl_key"               => '/etc/mysql/server-key.pem'
           #},
        #"debian_family"       => {
           #  "basedir"              => '/usr',
           #  "datadir"              => '/var/lib/mysql',
           #  "tmpdir"               => '/tmp',
           #  "service_name"         => 'mysql',
           #  "client_package_name"  => 'mysql-client',
           #  "server_package_name"  => 'mysql-server',
           #  "socket"               => '/var/run/mysqld/mysqld.sock',
           #  "pidfile"              => '/var/run/mysqld/mysqld.pid',
           #  "config_file"          => '/etc/mysql/my.cnf',
           #  "log_error"            => '/var/log/mysql/error.log',
           #  "ruby_package_name"    => 'libmysql-ruby',
           #  "python_package_name"  => 'python-mysqldb',
           #  "php_package_name"     => 'php5-mysql',
           #  "java_package_name"    => 'libmysql-java',
           #  "root_group"           => 'root',
           #  "ssl_ca"               => '/etc/mysql/cacert.pem',
           #  "ssl_cert"             => '/etc/mysql/server-cert.pem',
           #  "ssl_key"              => '/etc/mysql/server-key.pem',
           # }
      
           "db" => {
              "charset" => "utf8",
              "host" => "localhost",
              "grant" => ['all']
           }
    }

    COUCHBASE_DEFAULTS = {
      "size" => "1024",
      "user" => "couchbase", 
      "password" => "password",
      "version" => "latest",
      "bucket" => {
        "port" => "8091",
        "size" => "1024",
        "user" => "couchbase",
        "password" => "password",
        "type" => "memcached",
        "replica" => "1"
      }
    }
    
    TOMCAT_DEFAULTS = {
      "instance" => {
        "group" => "adm",
        "owner" => "tomcat",
        "server_port" => "8005",
        "http_port" => "8080", 
        "ajp_port" => "8009"
      }
    }
  	attr_accessible :body, #Content of the flow
          					:name, #Name of this flow
                    :hash_attributes,
                    :kind
    serialize :hash_attributes, Hash 

    validates :name, :presence => { :message => "El flujo debe llevar un nombre."},
                     :uniqueness => { :case_sensitive => true, :message => "Nombre de flujo ya en uso." }, :on => :create

    validates :hash_attributes, :hash_attributes => true, :on => :update                    

  	belongs_to :user
    has_many :configurations
    has_many :nodes, :through => :configurations
  	
  	def self.defaults(tool)
      case tool
        when "mysql" then MYSQL_DEFAULTS
        when "couchbase" then COUCHBASE_DEFAULTS
        else TOMCAT_DEFAULTS
      end
    end

  	
end

