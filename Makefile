include environment.mk
# at some point, in the future, clean this mess up...
appName = dotter
DEVICE ?= fr735xt
devices = $(shell grep 'iq:product id=' manifest.xml | sed 's/.*iq:product id="\([^"]*\).*/\1/')
version = $(shell date +%Y%m%d%H%M)
KEY_DIR ?= .key
PWD = $(shell pwd)
BIN_DIR = bin
BIN=${PWD}/${BIN_DIR}/${appName}.prg

MONKEYC_FLAG = --jungles ./monkey.jungle \
	       --private-key ${PRIVATE_KEY} \
	       --warn \
	       -l 0

MONKEYC_BLD = --device ${DEVICE} \
	       --output ${BIN_DIR}/${appName}.prg

MONKEYC_PKG = --output ${BIN_DIR}/${appName}.iq \
	      --package-app \
	      --release

default: bld

bld:
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} ${MONKEYC_BLD}

info:
	$(info info:  ${})
	$(info pkey: ${PRIVATE_KEY})
	$(info sdk:  ${SDK_HOME})
	$(info app version:  ${version})

sim:
	$(info run shell script to start simulator)
	@$(shell ./script/sim.sh ${SDK_HOME} simulator)

run: build killmonkeydo
	$(info run shell script to start watch)
	@$(shell ./script/sim.sh ${SDK_HOME} run ${BIN} ${DEVICE})

killmonkeydo:
	$(shell pkill monkeydo)

killsim: killmonkeydo
	$(shell pkill simulator)

clean:
	@rm -f ${BIN_DIR}/$(appName).prg

deploy: package
	@cp ${BIN_DIR}/$(appName).iq ${DEPLOY}/${appName}.${version}.iq

pkg: info
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} ${MONKEYC_PKG}

build: bld info

package: pkg

gendevkey:
	$(info this might work, needs testing)
	@mkdir ${KEY_DIR}
	$(shell openssl req -x509 -newkey rsa:4096 -keyout ${KEY_DIR}/grsa.pem -nodes -out ${KEY_DIR}/crsa.pem -subj "/CN=unused")
	$(shell openssl pkcs8 -topk8 -inform PEM -outform DER -in ${KEY_DIR}/grsa.pem -nocrypt -out ${KEY_DIR}/grsa.der)

build-debug: info
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} \
	-o ${BIN_DIR}/$(appName).prg \
	-d $(DEVICE)_sim \
	--debug

uuidgen:
	$(info make uuid for manifest.xml)
	@uuidgen -t

buildall:
	$(info devices:  ${devices})
	@$(shell for device in ${devices}; do \
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} \
		--device $$device \
		--output ${BIN_DIR}/$(appName).$$device.prg; \
	done)

.PHONY: default killsim killmonkeydo uuidgen test package build info clean
