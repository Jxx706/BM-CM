require 'yaml'
#string => hash
	def parse_report(yaml_string)

		lines = (yaml_string.lines).to_a

		result = lines.map do |e|
					e = e.gsub(/(!ruby\/object[\w\d:.]*)/, '')
				end

		return YAML.load(result.join)
	end	