# == Schema Information
#
# Table name: flows
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  node_name       :string(255)
#  user_id         :integer
#  hash_attributes :text
#  body            :string(255)
#

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
          					:node_name, #Name of the node that owns this flow
                    :hash_attributes
    serialize :hash_attributes, Hash 
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
