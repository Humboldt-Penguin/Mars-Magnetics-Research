class Logger:
	def __init__(self):
		self.logs = ''
		
	def log(self, newlog, endl='\n'):
		logs += str(newlog) + endl
		
	
	def writeLogs(self, path, fn='default'):
		if (fn == 'default'):
			# make it logs_date_time, however tf that's done
