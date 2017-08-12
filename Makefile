NGINX_VER = 1.11.13
MODULE_NAME=ngx_rust
MODULE_LIB=${MODULE_SRC}/nginx-${NGINX_VER}/objs/${MODULE_NAME}.so
NGX_DEBUG="--with-debug"
DARWIN_NGINX=nginx-darwin
LINUX_NGINX=nginx-linux
RUST_COMPILER_TAG = 0.1
RUST_TOOL = gcr.io/$(GCLOUD_PROJECT)/ngx-mixer-dev:${RUST_COMPILER_TAG}
export ROOT_DIR=${PWD}

darwin-source:
	wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz
	tar zxf nginx-${NGINX_VER}.tar.gz
	mv nginx-${NGINX_VER} ${DARWIN_NGINX}
	mv ${DARWIN_NGINX} nginx
	rm nginx-${NGINX_VER}.tar.gz*

darwin-configure:
	cd nginx/${DARWIN_NGINX}; \
    ./configure --add-dynamic-module=../../module

darwin-setup:   darwin-source darwin-configure

# need to run inside container
lx-compiler:
	docker run -it -v ${ROOT_DIR}:/src ${RUST_TOOL}  /bin/bash


linux-source:
	wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz
	tar zxf nginx-${NGINX_VER}.tar.gz
	mv nginx-${NGINX_VER} ${LINUX_NGINX}
	mv ${LINUX_NGINX} nginx
	rm nginx-${NGINX_VER}.tar.gz*


lx-configure:
	docker run -it -v ${ROOT_DIR}:/src -w /src/ ${RUST_TOOL} make docker-linux-configure


linux-setup:    linux-source lx-configure


lx-build:
	docker run -it -v ${ROOT_DIR}:/src -w /src/ ${RUST_TOOL} cargo build


# this run inside container
docker-linux-configure:
	cd nginx/${LINUX_NGINX}; \
    ./configure --add-dynamic-module=../../module



clean:
	cargo clean
	rm -f src/bindings.rs


super_clean: clean
	rm -rf nginx