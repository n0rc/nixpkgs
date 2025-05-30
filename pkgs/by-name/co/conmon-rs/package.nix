{
  capnproto,
  lib,
  fetchFromGitHub,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "conmon-rs";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "conmon-rs";
    rev = "v${version}";
    hash = "sha256-1kGAUAmiPI9zE8LE7G2r0Gy0YM+BUy2MxY7IQOu2ZDQ=";
  };

  nativeBuildInputs = [
    capnproto
    protobuf
  ];
  doCheck = false;

  cargoVendorDir = ".cargo-vendor";

  meta = with lib; {
    description = "OCI container runtime monitor written in Rust";
    homepage = "https://github.com/containers/conmon-rs";
    license = licenses.asl20;
    teams = [ teams.podman ];
    platforms = platforms.linux;
  };
}
