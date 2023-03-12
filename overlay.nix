{ pkgs_x86 }:
self: super: {
  ldb = super.ldb.overrideAttrs (oldAttrs: rec {
    #NOTE(): backported ldb build from later branch:
    # otherwise the configure script fails with
    # PYTHONHASHSEED=1 missing! Don't use waf directly, use ./configure and make!
    preConfigure = ''
      export PKGCONFIG="$PKG_CONFIG"
      export PYTHONHASHSEED=1
    '';

    wafPath = "buildtools/bin/waf";

    wafConfigureFlags = [
      "--bundled-libraries=NONE"
      "--builtin-libraries=replace"
      "--without-ldb-lmdb"
    ];

    # python-config from build Python gives incorrect values when cross-compiling.
    # If python-config is not found, the build falls back to using the sysconfig
    # module, which works correctly in all cases.
    PYTHON_CONFIG = "/invalid";
  });
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
