{
  lib,
  buildGoModule,
  fetchFromGitHub,
# versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "discord-rpc-lsp";
  version = "1.0.1";

  # src = fetchFromGitHub {
  #   owner = "zerootoad";
  #   repo = finalAttrs.pname;
  #   tag = finalAttrs.version;
  #   hash = "sha256-1Zw+F/EfYjHHU0AYlAHT7g1sbuJrHRtGp9E1u9EPW8E=";
  # };

  src = fetchFromGitHub {
    owner = "HadziqM";
    repo = finalAttrs.pname;
    rev = "59ac2a1c9356961846608f01544abf0c879b32ec";
    hash = "sha256-pn2gto2EW/24UMsXuuNcjOfaLdS3MoQ2/XirWtB594M=";
  };

  vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";

  # nativeBuildInputs = [
  #   versionCheckHook
  # ];

  meta = {
    description = "A Language Server Protocol (LSP) to share your discord rich presence. ";
    homepage = "https://github.com/zerootoad/discord-rpc-lsp";
    changelog = "https://github.com/zerootoad/discord-rpc-lsp/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [
      hadziqM
    ];
    mainProgram = "discord-rpc-lsp";
  };
})
