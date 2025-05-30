{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  tbb_2021_11,

  useTBB ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libblake3";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "BLAKE3-team";
    repo = "BLAKE3";
    tag = finalAttrs.version;
    hash = "sha256-IABVErXWYQFXZcwsFKfQhm3ox7UZUcW5uzVrGwsSp94=";
  };

  sourceRoot = finalAttrs.src.name + "/c";

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = lib.optionals useTBB [
    # 2022.0 crashes on macOS at the moment
    tbb_2021_11
  ];

  cmakeFlags = [
    (lib.cmakeBool "BLAKE3_USE_TBB" useTBB)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  meta = {
    description = "Official C implementation of BLAKE3";
    homepage = "https://github.com/BLAKE3-team/BLAKE3/tree/master/c";
    license = with lib.licenses; [
      asl20
      cc0
    ];
    maintainers = with lib.maintainers; [
      fgaz
      fpletz
      silvanshade
    ];
    platforms = lib.platforms.all;
  };
})
