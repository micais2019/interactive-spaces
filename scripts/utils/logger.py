import logging
import logging.handlers
from pathlib import Path
import json

LOG_FILENAME = 'logs/logger_test.log'
# logging.basicConfig(level=logging.DEBUG)

class Logger:
    def __init__(self, filename=LOG_FILENAME):
        self.filename = str(Path(filename).resolve())

        # make sure logfile exists
        Path(self.filename).touch()

        print("starting logfile at", self.filename)

        fh = logging.handlers.RotatingFileHandler(
            self.filename, mode='a', maxBytes=pow(2, 26), backupCount=5
        )
        fh.setLevel(logging.INFO)

        formatter = logging.Formatter('%(levelname)s,%(asctime)s.%(msecs)d,%(message)s', '%s')
        fh.setFormatter(formatter)

        self.logger = logging.getLogger(__name__)
        self.logger.addHandler(fh)
        self.logger.setLevel(logging.DEBUG)

    def info(self, message):
        self.logger.info(message)

    def debug(self, message):
        self.logger.debug(json.dumps(str(message)))

    def warning(self, message):
        self.logger.warning(json.dumps(str(message)))

    def error(self, message):
        self.logger.error(json.dumps(str(message)))


if __name__ == '__main__':
    import time
    from random import random, randint

    logger = Logger()

    logger.debug('This message should appear on the console')
    logger.info('So should "this", and it\'s using quoting...')
    logger.warning('And this, too')

    while True:
        logger.info(randint(10, 75))
        time.sleep(random() * 2)
