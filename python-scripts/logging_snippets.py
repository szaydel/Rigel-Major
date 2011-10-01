#!/usr/bin/python3.1


## Establish our root logger
root_logger = logging.getLogger('main_logger')

## Set level for root logger
root_logger.setLevel(logging.INFO)

console_log = logging.StreamHandler(sys.stderr)
console_log.setLevel(logging.INFO)
console_log.setFormatter(console_fmt)
root_logger.addHandler(console_log)