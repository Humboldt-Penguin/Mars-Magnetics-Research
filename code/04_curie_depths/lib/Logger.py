class Logger:
	def __init__(self):
		self.logs = ''
		
	def log(self, newlog, endl='\n'):
		'''
		Log a message by adding to the existing set of logs.
		'''
		self.logs += str(newlog) + endl
		
	
	def writeLogs(self, path, fn='default'):
		if (fn == 'default'):
			# make it logs_date_time, however tf that's donei

# there's only so much medication can help
# cause i'm sick and i won't ever be getting well
