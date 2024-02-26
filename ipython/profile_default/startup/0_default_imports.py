import logging
from glob import glob
from datetime import datetime, timedelta
from pdb import set_trace as st
import json
import os
from pathlib import Path
import traceback

# logging.basicConfig(level=logging.INFO, format='[%(levelname)s %(asctime)s] %(message)s',
#                     datefmt='%m/%d/%Y %I:%M:%S %p')

try:
    import pandas as pd
    import numpy as np
except Exception as e:
    logging.errors = getattr(logging, 'errors', [])
    tb = traceback.format_exc()
    logging.errors.append((e, tb))


def try_magic(m):
    try:
        get_ipython().magic(m)
    except Exception as e:
        logging.errors = getattr(logging, 'errors', [])
        tb = traceback.format_exc()
        logging.errors.append((e, tb))


# try_magic(u'%load_ext line_profiler')

try_magic(u'%load_ext autoreload')
try_magic(u'%autoreload 2')
