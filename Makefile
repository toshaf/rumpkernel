RUMP=~/code/rumprun/rumprun/bin/

bin/unikernel.native: unikernel.c
	mkdir -p bin
	gcc -o bin/unikernel.native unikernel.c

bin/unikernel: unikernel.c
	mkdir -p bin
	$(RUMP)x86_64-rumprun-netbsd-gcc -o bin/unikernel unikernel.c

bin/unikernel.baked: bin/unikernel
	$(RUMP)rumprun-bake hw_generic bin/unikernel.baked bin/unikernel

.PHONY:run_unikernel
run_unikernel: bin/unikernel.baked
	$(RUMP)rumprun qemu -i -I if,vioif,'-net tap,script=no,ifname=tap0' -W if,inet,static,10.0.120.101/24 -M 128 bin/unikernel.baked

bin/server: server.c
	mkdir -p bin
	$(RUMP)x86_64-rumprun-netbsd-gcc -o bin/server server.c

bin/server.baked: bin/server
	$(RUMP)rumprun-bake hw_generic bin/server.baked bin/server

.PHONY:run_server
run_server: bin/server.baked
	$(RUMP)rumprun qemu -i -I if,vioif,'-net tap,script=no,ifname=tap0' -W if,inet,static,10.0.120.101/24 -M 128 bin/server.baked
