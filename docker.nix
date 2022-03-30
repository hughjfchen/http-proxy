{ nativePkgs ? (import ./default.nix {}).pkgs,
crossBuildProject ? import ./cross-build.nix {} }:
nativePkgs.lib.mapAttrs (_: prj:
with prj.http-proxy;
let
  executable = http-proxy.http-proxy.components.exes.http-proxy;
  binOnly = prj.pkgs.runCommand "http-proxy-bin" { } ''
    mkdir -p $out/bin
    cp ${executable}/bin/http-proxy $out/bin
    ${nativePkgs.nukeReferences}/bin/nuke-refs $out/bin/http-proxy
  '';
in { 
  http-proxy-image = prj.pkgs.dockerTools.buildImage {
  name = "http-proxy";
  tag = executable.version;
  contents = [ binOnly prj.pkgs.cacert prj.pkgs.iana-etc ];
  config.Entrypoint = "http-proxy";
  config.Cmd = "--help";
  };
}) crossBuildProject
