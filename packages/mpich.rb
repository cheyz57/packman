class Mpich < PACKMAN::Package
  url 'http://www.mpich.org/static/downloads/3.1.2/mpich-3.1.2.tar.gz'
  sha1 'c5199be7e9f1843b288dba0faf2c071c7a8e999d'
  version '3.1.2'

  # conflicts_with 'openmpi'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-maintainer-mode
      --enable-fortran=all
      --enable-cxx
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end