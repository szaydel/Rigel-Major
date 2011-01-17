#!/usr/bin/python3.1
#
##
###
###
import logging
# set up logging to file - see previous section for more details
logging.basicConfig(level=logging.DEBUG,
    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
    datefmt='%m/%d %I:%M:%S %p',
    # filename='/temp/myapp.log',
    # filemode='w'
    )


# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.FileHandler('/tmp/mylog.file', mode='a')
console.setLevel(logging.INFO)

# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')

# tell the handler to use this format
console.setFormatter(formatter)

# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger. First the root...
logging.info('Jackdaws love my big sphinx of quartz.')

# Now, define a couple of other loggers which might represent areas in your
# application:
logger1 = logging.getLogger('myapp.area1')
logger2 = logging.getLogger('myapp.area2')
logger1.debug('Quick zephyrs blow, vexing daft Jim.')
logger1.info('How quickly daft jumping zebras vex.')
logger2.warning('Jail zesty vixen who grabbed pay from quack.')
logger2.error('The five boxing wizards jump quickly.')



#myformat = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s",
#                             "%b %d %H:%M:%S")
#
#logger = logging.getLogger('Logname')
#logger.setLevel(logging.DEBUG)
## create file handler which logs even debug messages
#fh = logging.FileHandler('/tmp/mylog.log')
#fh.setLevel(logging.DEBUG)
## create console handler with a higher log level
#ch = logging.StreamHandler()
#ch.setLevel(logging.ERROR)
## create formatter and add it to the handlers
#
#ch.setFormatter(myformat)
#fh.setFormatter(myformat)
## add the handlers to logger
#logger.addHandler(ch)
#logger.addHandler(fh)
#logger.info('This is Info')
#logger.warn('This is a Warning')
#fh = logging.FileHandler('/tmp/mylog.log')