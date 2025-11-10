{ pkgs, ... }:
let
  dummy = pkgs.writeShellApplication {
    name = "dummy";
    text = ''
      while true; do echo "test";sleep 5; done
    '';
  };
  service = pkgs.writeText "test-idk.service" ''
    [Unit]
    Description=Print 'test' continuously

    [Service]
    ExecStart=${dummy}/bin/dummy
    Restart=always

    [Install]
    WantedBy=default.target
  '';
in
pkgs.symlinkJoin {
  name = "dummy";
  paths = [ dummy ];
  postBuild = ''
    mkdir -p $out/share/systemd/user
    cp ${service} $out/share/systemd/user/test-idk.service
  '';
}
