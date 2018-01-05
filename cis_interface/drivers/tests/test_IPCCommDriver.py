import unittest
from cis_interface.tools import is_ipc_installed
from cis_interface.drivers.tests import test_CommDriver as parent


@unittest.skipIf(not is_ipc_installed(), "IPC library not installed")
class TestIPCCommParam(parent.TestCommParam):
    r"""Test parameters for the IPCCommDriver class."""
    def __init__(self, *args, **kwargs):
        super(TestIPCCommParam, self).__init__(*args, **kwargs)
        self.driver = 'IPCCommDriver'
        self.comm_name = 'IPCComm'
    

@unittest.skipIf(not is_ipc_installed(), "IPC library not installed")
class TestIPCCommDriverNoStart(TestIPCCommParam, parent.TestCommDriverNoStart):
    r"""Test class for the IPCCommDriver class without start."""
    pass


@unittest.skipIf(not is_ipc_installed(), "IPC library not installed")
class TestIPCCommDriver(TestIPCCommParam, parent.TestCommDriver):
    r"""Test class for the IPCCommDriver class."""
    pass
