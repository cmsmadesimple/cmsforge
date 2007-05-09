class Date

	def format(format = '%Y-%m-%d')
		begin
			Time.parse(self.to_s).strftime(format)
		rescue
			self.to_s
		end
	end

end
