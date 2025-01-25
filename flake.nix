{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    {
      self,
      utils,
      nixpkgs,
    }@inputs:
    let
      lib = nixpkgs.lib;
      version = "1.0.0";
    in
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        makeIosevkaFont =
          set: mode: plan:
          let
            dist-dir =
              if mode == "super-ttc" then
                ".super-ttc"
              else if mode == "ttc" then
                ".ttc/${plan}"
              else
                "${plan}/TTF";
            fontdir-target = if mode == "super-ttc" || mode == "ttc" then "TTC" else "TTF";
          in
          (pkgs.buildNpmPackage {
            pname = "iosevka-${set}-${mode}";
            inherit version;

            src = ./.;

            nativeBuildInputs = with pkgs; [
              ttfautohint-nox
            ];

            npmDepsHash = "sha256-Qr7fN49qyaqaSutrdT7HjWis7jjwYR/S2kxkHs7EhXY=";

            # npmBuildFlags = [
            #   "--"
            #   "--targets=${mode}::${plan}"
            #   "--jCmd=$NIX_BUILD_CORES"
            #   "--verbose=9"
            # ];

            buildPhase = ''
              runHook preBuild
              npm run build -- --targets=${mode}::${plan} --jCmd=$NIX_BUILD_CORES --verbose=9
              runHook postBuild
            '';

            npmPackFlags = [ "--ignore-scripts" ];

            installPhase = ''
              runHook preInstall
              fontdir="$out/share/fonts/${fontdir-target}/${plan}"
              install -d "$fontdir"
              install "dist/${dist-dir}"/* "$fontdir"
              runHook postInstall
            '';

            enableParallelBuilding = true;

            meta = {
              homepage = "https://github.com/Sharparam/Iosevka";
              description = "Iosevka Sharpie";
              license = lib.licenses.ofl;
              platforms = lib.platforms.all;
            };
          });
      in
      {
        packages = {
          default = makeIosevkaFont "sharpie" "super-ttc" "IosevkaSharpie";
          ttc = makeIosevkaFont "sharpie" "ttc" "IosevkaSharpie";
          ttf = makeIosevkaFont "sharpie" "ttf" "IosevkaSharpie";
          term-ttf = makeIosevkaFont "sharpie-term" "ttf" "IosevkaSharpieTerm";
          fixed-ttf = makeIosevkaFont "sharpie-fixed" "ttf" "IosevkaSharpieFixed";
          aile-super-ttc = makeIosevkaFont "sharpie-aile" "super-ttc" "IosevkaSharpieAile";
          aile-ttc = makeIosevkaFont "sharpie-aile" "ttc" "IosevkaSharpieAile";
          aile-ttf = makeIosevkaFont "sharpie-aile" "ttf" "IosevkaSharpieAile";
          etoile-super-ttc = makeIosevkaFont "sharpie-etoile" "super-ttc" "IosevkaSharpieEtoile";
          etoile-ttc = makeIosevkaFont "sharpie-etoile" "ttc" "IosevkaSharpieEtoile";
          etoile-ttf = makeIosevkaFont "sharpie-etoile" "ttf" "IosevkaSharpieEtoile";
        };
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            ttfautohint-nox
            prefetch-npm-deps
          ];
        };
      }
    );
}
