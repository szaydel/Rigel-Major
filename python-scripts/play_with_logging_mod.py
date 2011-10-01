#!/usr/bin/python3.1

import logging, logging.handlers

def main():
    from socket import gethostname
    gethostname()

    LOG_FMT = '%(asctime)s %(gethostname())s %(name)s %(levelname)-8s %(message)s'
    DATE_FMT='%b %d %H:%M:%S'
    logging.basicConfig(filename='/tmp/logging.log',level=logging.DEBUG,
                    format=LOG_FMT,
                    datefmt=DATE_FMT,)
    logging.debug('This message should go to the log file')
    logging.info('So should this')
    print('Doing something here...')
    logging.warning('And this, too')
    
    ## Custom logger Create
    c_logger = logging.getLogger('level_1')
    c_logger.setLevel(logging.DEBUG)
    
    ## Custom logger Handler Create
    c_handler = logging.handlers.SysLogHandler(address='/dev/log')
    c_handler.

if __name__ == '__main__':
    main()


import logging, logging.handlers
c_logger = logging.getLogger('')
c_logger.setLevel(logging.DEBUG)
c_handler = logging.handlers.SysLogHandler(address='/dev/log')
c_handler.setLevel(logging.DEBUG)
c_fmt = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
c_logger.addHandler(c_handler)
c_logger.debug('Yo yo yo')