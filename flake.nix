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
        makeIosevkaFont = set: mode: plan: (
          pkgs.buildNpmPackage {
            pname = "iosevka-${set}-${mode}";
            inherit version;

            src = ./.;

            nativeBuildInputs = with pkgs; [
              ttfautohint-nox
            ];

            npmDepsHash = "sha256-Qr7fN49qyaqaSutrdT7HjWis7jjwYR/S2kxkHs7EhXY=";

            npmBuildFlags = ["--" "${mode}::${plan}"];

            npmPackFlags = [ "--ignore-scripts" ];

            installPhase = ''
              runHook preInstall
              fontdir="$out/share/fonts/TTC/Iosevka Sharpie"
              install -d "$fontdir"
              install "dist/.supeer-ttc"/* "$fontdir"
              runHook postInstall
            '';

            meta = {
              homepage = "https://github.com/Sharparam/Iosevka";
              description = "Iosevka Sharpie";
              license = lib.licenses.ofl;
              platforms = lib.platforms.all;
            };
          }
        );
      in
      {
        packages = {
          default = makeIosevkaFont "sharpie" "super-ttc" "IosevkaSharpie";
          ttc = makeIosevkaFont "sharpie" "ttc" "IosevkaSharpie";
          ttf = makeIosevkaFont "sharpie" "ttf" "IosevkaSharpie";
          term-ttc = makeIosevkaFont "sharpie-term" "ttc" "IosevkaSharpieTerm";
          fixed-ttc = makeIosevkaFont "sharpie-fixed" "ttc" "IosevkaSharpieFixed";
          term-ttf = makeIosevkaFont "sharpie-term" "ttf" "IosevkaSharpieTerm";
          fixed-ttf = makeIosevkaFont "sharpie-fixed" "ttf" "IosevkaSharpieFixed";
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
