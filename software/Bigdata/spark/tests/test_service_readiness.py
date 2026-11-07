import subprocess
from unittest.mock import Mock, patch
import pytest
from runtime import Runtime


def test_yarn_waits_for_rpc_and_survives_transient_cli_timeout():
    r = Runtime.__new__(Runtime)
    r.wait_port = Mock()
    r.run = Mock(side_effect=[subprocess.TimeoutExpired('yarn',30), 'Total Nodes:0', 'Total Nodes:1'])
    with patch('runtime.time.sleep'):
        r.wait_yarn()
    assert 8032 in [call.args[0] for call in r.wait_port.call_args_list]
    assert r.run.call_count == 3


@pytest.mark.parametrize('result', [subprocess.TimeoutExpired('yarn',30), 'Total Nodes:0'])
def test_yarn_missing_registration_still_fails_at_deadline(result):
    r = Runtime.__new__(Runtime)
    r.wait_port = Mock()
    r.run = Mock(side_effect=result) if isinstance(result, Exception) else Mock(return_value=result)
    with patch('runtime.time.monotonic',side_effect=[0,601]), pytest.raises(RuntimeError,match='YARN NodeManager'):
        r.wait_yarn()
