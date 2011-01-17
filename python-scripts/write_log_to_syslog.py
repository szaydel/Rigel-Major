import logging
import logging.handlers

logging.basicConfig(level=logging.DEBUG,
format='%(asctime)s %(levelname)-8s %(message)s',
datefmt='%a, %d %b %Y %H:%M:%S',
# filename='/tmp/myapp.log',
filemode='w')

syslog_hlr = logging.handlers.SysLogHandler(address='/dev/log')
syslog_hlr.setLevel(logging.INFO)
mylogger = logging.getLogger('mylogfile').addHandler(syslog_hlr)
logging.info('Test message')