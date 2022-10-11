{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "helix-gpt";
  version = "0.18";

  src = fetchurl {
    url = "https://github.com/leona/helix-gpt/releases/download/${version}/${pname}-${version}-x86_64-linux.tar.gz";
    sha256 = "sha256-oTL/otKuij/mMbLS8VbFHKmMl24nAlvBManvz44Ytu4=";
  };

  sourceRoot = ".";

  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname}-${version}-x86_64-linux $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Code completion LSP for Helix with support for Copilot + OpenAI";
    homepage = "https://github.com/leona/helix-gpt";
    license = licenses.mit;
    maintainers = with maintainers; [xlambein];
    mainProgram = "helix-gpt";
    platforms = platforms.all;
  };
}
