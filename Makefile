include environment.mk
# at some point, clean this mess up...
appName = appName
DEVICE ?= fr735xt
devices = $(shell grep 'iq:product id=' manifest.xml | sed 's/.*iq:product id="\([^"]*\).*/\1/')
version = $(shell date +%Y%m%d%H%M)
JAVA_OPTIONS += JDK_JAVA_OPTIONS="--add-modules=java.xml.bind"
KEY_DIR ?= .key
PWD = $(shell pwd)
BIN=${PWD}/bin/${appName}.prg

MONKEYC_FLAG = --jungles ./monkey.jungle \
	       --private-key ${PRIVATE_KEY} \
	       --warn \
	       -l 0

MONKEYC_BLD = --device ${DEVICE} \
	       --output bin/${appName}.prg

MONKEYC_PKG = --output bin/${appName}.iq \
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

connect:
	$(info run shell script to start sim)
	@$(shell ./script/sim.sh ${SDK_HOME} sim)

sim: build killmonkeydo
	$(info run shell script to start watch)
	@$(shell ./script/sim.sh ${SDK_HOME} mon ${BIN} ${DEVICE})

killmonkeydo:
	$(shell pkill monkeydo)

killsim: killmonkeydo
	$(shell pkill simulator)

run: build
	"$(SDK_HOME)/bin/connectiq" &&\
	sleep 3 && \
	$(SDK_HOME)bin/monkeydo bin/$(appName).prg $(DEVICE)

clean:
	@rm -f bin/$(appName).prg

deploy: package
	@cp bin/$(appName).iq ${DEPLOY}/${appName}.version.iq

pkg: info
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} ${MONKEYC_PKG}

build: bld info

package: pkg

test: build
	@$(SDK_HOME)/bin/connectiq &&\
	sleep 3 &&\
	$(JAVA_OPTIONS) \
	"$(SDK_HOME)/bin/monkeydo" bin/$(appName).prg $(DEVICE) -t testSortExchange

gendevkey:
	$(info this might work, needs testing)
	@mkdir ${KEY_DIR}
	$(shell openssl req -x509 -newkey rsa:4096 -keyout ${KEY_DIR}/grsa.pem -nodes -out ${KEY_DIR}/crsa.pem -subj "/CN=unused")
	$(shell openssl pkcs8 -topk8 -inform PEM -outform DER -in ${KEY_DIR}/grsa.pem -nocrypt -out ${KEY_DIR}/grsa.der)

build-debug: info
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} \
	-o bin/$(appName).prg \
	-d $(DEVICE)_sim \
	--debug \
	-w -l 0 

uuidgen:
	$(info make uuid for manifest.xml)
	@uuidgen -t

buildall:
	$(info devices:  ${devices})
	@$(shell for device in ${devices}; do \
	${SDK_HOME}/bin/monkeyc  ${MONKEYC_FLAG} \
		--device $$device \
		--output bin/$(appName).$$device.prg; \
	done)
