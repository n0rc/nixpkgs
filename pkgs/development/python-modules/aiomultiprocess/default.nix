{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  flit-core,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "aiomultiprocess";
  version = "0.9.1";
  pyproject = true;

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "omnilib";
    repo = "aiomultiprocess";
    tag = "v${version}";
    hash = "sha256-LWrAr3i2CgOMZFxWi9B3kiou0UtaHdDbpkr6f9pReRA=";
  };

  build-system = [ flit-core ];

  nativeCheckInputs = [ pytestCheckHook ];

  enabledTestPaths = [ "aiomultiprocess/tests/*.py" ];

  disabledTests = [
    # tests are flaky and make the whole test suite time out
    "test_pool_worker_exceptions"
    "test_pool_worker_max_tasks"
    "test_pool_worker_stop"
    # error message changed with python 3.12
    "test_spawn_method"
  ];

  pythonImportsCheck = [ "aiomultiprocess" ];

  meta = with lib; {
    description = "Python module to improve performance";
    longDescription = ''
      aiomultiprocess presents a simple interface, while running a full
      AsyncIO event loop on each child process, enabling levels of
      concurrency never before seen in a Python application. Each child
      process can execute multiple coroutines at once, limited only by
      the workload and number of cores available.
    '';
    homepage = "https://github.com/omnilib/aiomultiprocess";
    license = with licenses; [ mit ];
    maintainers = [ maintainers.fab ];
  };
}
