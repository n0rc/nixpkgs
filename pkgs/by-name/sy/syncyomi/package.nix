{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  nodejs,
  pnpm_9,
  esbuild,
}:

buildGoModule rec {
  pname = "syncyomi";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "SyncYomi";
    repo = "SyncYomi";
    tag = "v${version}";
    hash = "sha256-PPE6UXHo2ZlN0A0VkUH+8pkdfm6WEvpofusk6c3RBHk=";
  };

  vendorHash = "sha256-/rpT6SatIZ+GVzmVg6b8Zy32pGybprObotyvEgvdL2w=";

  web = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "${pname}-web";
    inherit src version;
    sourceRoot = "${finalAttrs.src.name}/web";

    pnpmDeps = pnpm_9.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      fetcherVersion = 1;
      hash = "sha256-edcZIqshnvM3jJpZWIR/UncI0VCMLq26h/n3VvV/384=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm_9.configHook
    ];

    env.ESBUILD_BINARY_PATH = lib.getExe (
      esbuild.override {
        buildGoModule =
          args:
          buildGoModule (
            args
            // rec {
              version = "0.17.19";
              src = fetchFromGitHub {
                owner = "evanw";
                repo = "esbuild";
                rev = "v${version}";
                hash = "sha256-PLC7OJLSOiDq4OjvrdfCawZPfbfuZix4Waopzrj8qsU=";
              };
              vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
            }
          );
      }
    );

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  });

  preConfigure = ''
    cp -r $web/* web/dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  postInstall = lib.optionalString (!stdenvNoCC.hostPlatform.isDarwin) ''
    mv $out/bin/SyncYomi $out/bin/syncyomi
  '';

  meta = {
    description = "Open-source project to synchronize Tachiyomi manga reading progress and library across multiple devices";
    homepage = "https://github.com/SyncYomi/SyncYomi";
    changelog = "https://github.com/SyncYomi/SyncYomi/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ eriedaberrie ];
    mainProgram = "syncyomi";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
