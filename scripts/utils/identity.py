# Importing socket library
from subprocess import check_output
import platform


# Function to display hostname and
# IP address
def get_identity():
    try:
        python_info = "({}, {} {})".format(
            platform.platform(),
            platform.python_implementation(),
            platform.python_version()
        )
        host_name = check_output(['hostname']).strip().decode("utf-8")
        host_ip = check_output(['hostname', '-I']).strip().decode("utf-8")
        return "{} {} {}".format(host_name, host_ip, python_info)
    except:
        return "unidentified"

