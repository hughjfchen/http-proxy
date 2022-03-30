{ nativePkgs ? (import ./default.nix {}).pkgs,
crossBuildProject ? import ./cross-build.nix {} }:
nativePkgs.lib.mapAttrs (_: prj:
with prj.http-proxy;
let
  executable = http-proxy.http-proxy.components.exes.http-proxy;
  binOnly = prj.pkgs.runCommand "http-proxy-bin" { } ''
    mkdir -p $out/bin
    cp -R ${executable}/bin/* $out/bin/
    ${nativePkgs.nukeReferences}/bin/nuke-refs $out/bin/http-proxy
  '';

  tarball = nativePkgs.stdenv.mkDerivation {
    name = "http-proxy-tarball";
    buildInputs = with nativePkgs; [ zip ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/
      zip -r -9 $out/http-proxy-tarball.zip ${binOnly}
    '';
  };
in {
 http-proxy-tarball = tarball;
}
) crossBuildProject
