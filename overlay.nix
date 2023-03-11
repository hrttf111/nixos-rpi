{ pkgs_x86 }:
self: super: {
  cups-filters = super.cups-filters.overrideAttrs (oldAttrs: rec {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-cups-config=${super.cups.dev}/bin/cups-config" ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs_x86.pkg-config super.glib.dev ];
    buildInputs = oldAttrs.buildInputs ++ [ super.cups.dev ];
  });
  splix = super.splix.overrideAttrs (oldAttrs: rec {
    nativeBuildInputs = [ super.cups.dev ];
    buildInputs = oldAttrs.buildInputs ++ [ super.cups.dev ];
    postPatch = oldAttrs.postPatch + ''

      substituteInPlace Makefile \
        --replace 'gcc' $CC \
        --replace 'g++' $CXX

      substituteInPlace rules.mk \
        --replace 'g++' $CXX \
    '';
  });
}
