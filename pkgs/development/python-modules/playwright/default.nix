{
  lib,
  stdenv,
  auditwheel,
  buildPythonPackage,
  gitMinimal,
  greenlet,
  fetchFromGitHub,
  pyee,
  python,
  pythonOlder,
  setuptools,
  setuptools-scm,
  playwright-driver,
  nixosTests,
  nodejs,
}:

let
  driver = playwright-driver;
in
buildPythonPackage rec {
  pname = "playwright";
  # run ./pkgs/development/python-modules/playwright/update.sh to update
  version = "1.50.0";
  pyproject = true;
  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-python";
    tag = "v${version}";
    hash = "sha256-g32QwEA4Ofzh7gVEsC++uA/XqT1eIrUH+fQi15SRxko=";
  };

  patches = [
    # This patches two things:
    # - The driver location, which is now a static package in the Nix store.
    # - The setup script, which would try to download the driver package from
    #   a CDN and patch wheels so that they include it. We don't want this
    #   we have our own driver build.
    ./driver-location.patch
  ];

  postPatch = ''
    # if setuptools_scm is not listing files via git almost all python files are excluded
    export HOME=$(mktemp -d)
    git init .
    git add -A .
    git config --global user.email "nixpkgs"
    git config --global user.name "nixpkgs"
    git commit -m "workaround setuptools-scm"

    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["setuptools==75.6.0", "setuptools-scm==8.1.0", "wheel==0.45.1", "auditwheel==6.2.0"]' \
                     'requires = ["setuptools", "setuptools-scm", "wheel"]'

    # setup.py downloads and extracts the driver.
    # This is done manually in postInstall instead.
    rm setup.py

    # Set the correct driver path with the help of a patch in patches
    substituteInPlace playwright/_impl/_driver.py \
      --replace-fail "@node@" "${lib.getExe nodejs}" \
      --replace-fail "@driver@" "${driver}/cli.js"
  '';

  nativeBuildInputs = [
    gitMinimal
    setuptools-scm
    setuptools
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [ auditwheel ];

  pythonRelaxDeps = [
    "greenlet"
    "pyee"
  ];

  propagatedBuildInputs = [
    greenlet
    pyee
  ];

  postInstall = ''
    ln -s ${driver} $out/${python.sitePackages}/playwright/driver
  '';

  # Skip tests because they require network access.
  doCheck = false;

  pythonImportsCheck = [ "playwright" ];

  passthru = {
    inherit driver;
    tests =
      {
        driver = playwright-driver;
        browsers = playwright-driver.browsers;
      }
      // lib.optionalAttrs stdenv.hostPlatform.isLinux {
        inherit (nixosTests) playwright-python;
      };
    # Package and playwright driver versions are tightly coupled.
    # Use the update script to ensure synchronized updates.
    skipBulkUpdate = true;
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "Python version of the Playwright testing and automation library";
    mainProgram = "playwright";
    homepage = "https://github.com/microsoft/playwright-python";
    license = licenses.asl20;
    maintainers = with maintainers; [
      techknowlogick
      yrd
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
