# == Schema Information
#
# Table name: tableless_models
#
#

#Class that implements a tableless model.
#All classes acting as model without table backend must inherite from this.

class TablelessModel < ActiveRecord::Base
	
	#We're providing empty columns (i.e., no table)
	#class_inheritable_accessor :columns
	#self.columns = []

	def self.columns()
		@columns ||= []
	end

	def self.column(name, sql_type = nil, default = nil, null = true)
		columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
	end

	#Override the save method to prevent exceptions
	def save(validate = true)
		validate ? valid? : true
	end
end
