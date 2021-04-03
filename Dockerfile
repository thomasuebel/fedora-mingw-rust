FROM fedora:33

#
# Set up system
#
RUN dnf -y update
RUN dnf clean all
RUN dnf install -y git cmake file gcc make man sudo tar gcc-c++ boost boost-devel

#
# Install Mingw64 windows libraries
#
RUN dnf install -y mingw64-gcc mingw64-freetype mingw64-cairo mingw64-harfbuzz mingw64-pango mingw64-poppler mingw64-gtk3 mingw64-winpthreads-static mingw64-glib2-static 

#
# Build peldd
#
WORKDIR /
RUN git clone https://github.com/gsauthof/pe-util
WORKDIR pe-util
RUN git submodule update --init
WORKDIR build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make
RUN mv /pe-util/build/peldd /usr/bin/peldd
RUN chmod +x /usr/bin/peldd

#
# Install Rust
#
RUN useradd -ms /bin/bash rust
USER rust
WORKDIR /home/rust/

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN /home/rust/.cargo/bin/rustup update

#
# Set up rust for cross compiling
#
RUN /home/rust/.cargo/bin/rustup target add x86_64-pc-windows-gnu
ADD cargo.config /home/rust/.cargo/config
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
ENV GTK_INSTALL_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/
