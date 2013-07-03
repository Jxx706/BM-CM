# == Schema Information
#
# Table name: flows
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file_path  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  node_name  :string(255)
#

class Flow < ActiveRecord::Base

      MYSQL_DEFAULTS = {
      "bind_address"        => '127.0.0.1',
      "config_template"     => 'mysql/my.cnf.erb',
      "default_engine"      => 'UNSET',
      "etc_root_password"   => false,
      "manage_service"      => true,
      "old_root_password"   => '',
      "package_ensure"      => 'present',
      "purge_conf_dir"      => false,
      "port"                => 3306,
      "max_allowed_packet"  => '16M',
      "root_password"       => 'UNSET',
      "restart"             => true,
      "ssl"                 => false,
      "redhat_family"       => { 
          "basedir"               => '/usr',
          "client_package_name"   => 'mysql',
          "config_file"           => '/etc/my.cnf',
          "datadir"               => '/var/lib/mysql',
          "tmpdir"                => '/tmp',
          "java_package_name"     => 'mysql-connector-java',
          "log_error"             => '/var/log/mysqld.log',
          "php_package_name"      => 'php-mysql',
          "pidfile"               => '/var/run/mysqld/mysqld.pid',
          "python_package_name"   => 'MySQL-python',
          "root_group"            => 'root',
          "ruby_package_name"     => 'ruby-mysql',
          "ruby_package_provider" => 'gem',
          "service_name"          => 'mysqld',
          "server_package_name"   => 'mysql-server',
          "socket"                => '/var/lib/mysql/mysql.sock',
          "ssl_ca"                => '/etc/mysql/cacert.pem',
          "ssl_cert"              => '/etc/mysql/server-cert.pem',
          "ssl_key"               => '/etc/mysql/server-key.pem'
         },
      "debian_family"       => {
          "basedir"              => '/usr',
          "datadir"              => '/var/lib/mysql',
          "tmpdir"               => '/tmp',
          "service_name"         => 'mysql',
          "client_package_name"  => 'mysql-client',
          "server_package_name"  => 'mysql-server',
          "socket"               => '/var/run/mysqld/mysqld.sock',
          "pidfile"              => '/var/run/mysqld/mysqld.pid',
          "config_file"          => '/etc/mysql/my.cnf',
          "log_error"            => '/var/log/mysql/error.log',
          "ruby_package_name"    => 'libmysql-ruby',
          "python_package_name"  => 'python-mysqldb',
          "php_package_name"     => 'php5-mysql',
          "java_package_name"    => 'libmysql-java',
          "root_group"           => 'root',
          "ssl_ca"               => '/etc/mysql/cacert.pem',
          "ssl_cert"             => '/etc/mysql/server-cert.pem',
          "ssl_key"              => '/etc/mysql/server-key.pem',
         }
    }

    COUCHBASE_DEFAULTS = {}
    TOMCAT_DEFAULTS = {}
  	attr_accessible :file_path, #Path where the flow is stored
  					:name, #Name of this flow
  					:node_name #Name of the node that owns this flow
  	belongs_to :user
  	before_save :path_ok?
  	
  	def self.defaults(tool)
      case tool
      when "mysql" then MYSQL_DEFAULTS
      when "couchbase" then COUCHBASE_DEFAULTS
      else TOMCAT_DEFAULTS
      end
    end
  	
    private
    #A path is ok when the file addressed by it exists.
  		def path_ok?
  			File.exists?(self.file_path)
  		end
end
