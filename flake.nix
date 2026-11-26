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
              "serif"
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

          # Web fonts: IBM's own pre-split woff2 files from the official npm
          # packages, so the site serves exactly what IBM publishes (OFL 1.1,
          # Reserved Font Name "Plex" stays valid because nothing is modified).
          # Only the Latin1 split of the five faces the stylesheet uses is
          # shipped. The PDF keeps using the nixpkgs fonts above.
          plexSansNpm = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@ibm/plex-sans/-/plex-sans-1.1.0.tgz";
            hash = "sha512-WPgvO6Yfj2w5YbhyAr1tv95RUz4LRJlqN+CmYvBglabXteufP1D1E9BABMde+ZIKdRbFJDoKF5eQzfhpnbgZcQ==";
          };
          plexMonoNpm = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@ibm/plex-mono/-/plex-mono-2.5.0.tgz";
            hash = "sha512-STBJIPxPomOYPmBMO7z5TKPJUotAF9u3gAUumTqVgwgrAO+K4FRNh0MlhsoJjKhJKsMbBJR10/bk4inkj/wc1w==";
          };
          plexSerifNpm = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@ibm/plex-serif/-/plex-serif-2.0.0.tgz";
            hash = "sha512-xVu9JsC18tBoQF2M6fofpsWrHj5a94saxlOZbYmXoC0E3UfjgS1JlibgrnaUJjnkLlEyCpMgI2PdhkDxijw0gA==";
          };

          webFonts = pkgs.runCommand "cv-web-fonts" { } ''
            mkdir sans mono serif $out
            tar -xzf ${plexSansNpm} -C sans --strip-components=1 package/fonts/split/woff2
            tar -xzf ${plexMonoNpm} -C mono --strip-components=1 package/fonts/split/woff2
            tar -xzf ${plexSerifNpm} -C serif --strip-components=1 package/fonts/split/woff2
            install -m644 \
              sans/fonts/split/woff2/IBMPlexSans-Regular-Latin1.woff2 \
              sans/fonts/split/woff2/IBMPlexSans-SemiBold-Latin1.woff2 \
              mono/fonts/split/woff2/IBMPlexMono-Regular-Latin1.woff2 \
              mono/fonts/split/woff2/IBMPlexMono-SemiBold-Latin1.woff2 \
              serif/fonts/split/woff2/IBMPlexSerif-Regular-Latin1.woff2 \
              $out/
            # OFL requires the licence to travel with the font files.
            install -m644 sans/fonts/split/woff2/license.txt $out/OFL.txt
          '';

          # Zola copies static/ into public/, so the fonts are staged there
          # before every `zola build` / `zola serve` (static/fonts is gitignored).
          installWebFonts = "${pkgs.coreutils}/bin/install -Dm644 -t static/fonts ${webFonts}/*";

          cvPackage = pkgs.stdenv.mkDerivation {
            name = "cv";
            src = ./.;
            buildInputs = [
              pkgs.zola
              pkgs.python3Packages.weasyprint
            ];
            FONTCONFIG_FILE = toString fontConfig;
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            buildPhase = ''
              ${installWebFonts}
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
                  languagetool-commandline -l en-GB -d WHITESPACE_RULE,UPPERCASE_SENTENCE_START,ARROWS,MORFOLOGIK_RULE_EN_GB,NUMBERS_IN_WORDS,OXFORD_SPELLING_Z_NOT_S ${./cv.yaml} > output.txt

                  # We grep for 'Rule ID' to see if there were actual grammar errors
                  if grep -q "Rule ID:" output.txt; then
                    echo "LanguageTool found errors:"
                    cat output.txt
                    exit 1
                  fi

                  # Touch $out so the derivation succeeds
                  touch $out
                '';
            ats =
              pkgs.runCommand "ats-check"
                {
                  buildInputs = [
                    pkgs.zola
                    pkgs.python3Packages.weasyprint
                    pkgs.poppler-utils
                  ];
                  FONTCONFIG_FILE = toString fontConfig;
                  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                }
                ''
                  cp -r ${./.} source
                  chmod -R u+w source
                  cd source

                  ${installWebFonts}
                  zola build
                  weasyprint public/index.html public/cv.pdf
                  pdftotext public/cv.pdf extracted.txt

                  if ! grep -q "Alex Wicks" extracted.txt; then
                    echo "ATS check failed: missing candidate name in extracted text"
                    exit 1
                  fi

                  if ! grep -iq "Experience" extracted.txt; then
                    echo "ATS check failed: missing Experience heading in extracted text"
                    exit 1
                  fi

                  if grep -Eq '^•[[:space:]]*$' extracted.txt; then
                    echo "ATS check failed: found orphan bullet markers in extracted text"
                    exit 1
                  fi

                  if grep -Eq '^•([[:space:]]*•)+[[:space:]]*$' extracted.txt; then
                    echo "ATS check failed: found repeated orphan bullet markers in extracted text"
                    exit 1
                  fi

                  mkdir -p $out
                  cp extracted.txt $out/
                '';
          };

          apps = {
            default = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "build-cv" ''
                  export FONTCONFIG_FILE=${fontConfig}
                  ${installWebFonts}
                  ${pkgs.zola}/bin/zola build
                  ${pkgs.python3Packages.weasyprint}/bin/weasyprint public/index.html cv.pdf
                  echo "Built cv.pdf successfully."
                ''
              );
            };
            serve = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "serve" ''
                  export FONTCONFIG_FILE=${fontConfig}
                  ${installWebFonts}
                  ${pkgs.zola}/bin/zola serve --extra-watch-path cv.yaml --open
                ''
              );
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.zola
              pkgs.python3Packages.weasyprint
              pkgs.poppler-utils
              fonts
              pkgs.fontconfig
              pkgs.languagetool
              config.treefmt.build.wrapper
            ];

            FONTCONFIG_FILE = toString fontConfig;

            shellHook = ''
              if [ -f config.toml ]; then ${installWebFonts}; fi
              echo "CV Development Environment"
              echo "Zola: $(zola --version)"
              echo "WeasyPrint: $(weasyprint --version)"
            '';
          };
        };
    };
}
