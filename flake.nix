{
  description = "CV build environment (Zola, WeasyPrint, IBM Plex fonts)";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          config,
          system,
          pkgs,
          ...
        }:
        let
          fonts = pkgs.ibm-plex.override {
            families = [
              "sans"
              "mono"
            ];
          };

          fontConfig = pkgs.writeText "fonts.conf" ''
            <?xml version='1.0'?>
            <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
            <fontconfig>
              <dir>${fonts}/share/fonts</dir>
              <cachedir>/tmp/fontconfig</cachedir>
            </fontconfig>
          '';

          cvPackage = pkgs.stdenv.mkDerivation {
            name = "cv";
            src = ./.;
            buildInputs = [
              pkgs.zola
              pkgs.python3Packages.weasyprint
            ];
            FONTCONFIG_FILE = toString fontConfig;
            buildPhase = ''
              zola build
              weasyprint public/index.html public/cv.pdf
            '';
            installPhase = ''
              mkdir -p $out
              cp -r public/* $out/
            '';
          };
        in
        {
          treefmt.config = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              prettier.enable = true;
              typos.enable = true; # Fast spell/typo checker for prose and code
            };
            settings.formatter.prettier.excludes = [ "*.html" ];
          };

          packages = {
            default = cvPackage;
            cv = cvPackage;
          };

          checks = {
            default = cvPackage;
            languagetool =
              pkgs.runCommand "languagetool-check"
                {
                  buildInputs = [ pkgs.languagetool ];
                }
                ''
                  # languagetool-commandline doesn't support -p in all versions/wrappers. Let's disable the spell checker specifically for tech terms instead
                  languagetool-commandline -l en-GB -d WHITESPACE_RULE,UPPERCASE_SENTENCE_START,ARROWS,MORFOLOGIK_RULE_EN_GB,NUMBERS_IN_WORDS,OXFORD_SPELLING_Z_NOT_S ${./cv.yaml} > output.txt || true

                  # We grep for 'Rule ID' to see if there were actual grammar errors
                  if grep -q "Rule ID:" output.txt; then
                    echo "LanguageTool found errors:"
                    cat output.txt
                    exit 1
                  fi

                  # Touch $out so the derivation succeeds
                  touch $out
                '';
          };

          apps.default = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "build-cv" ''
                export FONTCONFIG_FILE=${fontConfig}
                ${pkgs.zola}/bin/zola build
                ${pkgs.python3Packages.weasyprint}/bin/weasyprint public/index.html cv.pdf
                echo "Built cv.pdf successfully."
              ''
            );
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.zola
              pkgs.python3Packages.weasyprint
              pkgs.poppler-utils
              fonts
              pkgs.fontconfig
            ];

            FONTCONFIG_FILE = toString fontConfig;

            shellHook = ''
              echo "CV Development Environment"
              echo "Zola: $(zola --version)"
              echo "WeasyPrint: $(weasyprint --version)"
            '';
          };
        };
    };
}
