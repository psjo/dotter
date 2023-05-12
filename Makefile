include environment.mk

# fr735xt screen 215x180, icon 40x40
appName = appName
DEVICE ?= fr735xt
devices = $(grep 'iq:product id' manifest.xml | sed 's/.*iq:product id="\([^"]*\).*/\1/')
# Add one line in your source like var v = "1.0";
version = $(shell grep 'var v =' source/dotterApp.mc | sed 's/.*var v = "\([^"]*\).*/\1/')
JAVA_OPTIONS += JDK_JAVA_OPTIONS="--add-modules=java.xml.bind"
KEY_DIR ?= .key
PWD = $(shell pwd)
BIN=${PWD}/bin/${appName}.prg

default: build

build: info
	@$(JAVA_HOME)/bin/java \
	-Xms1g \
	-Dfile.encoding=UTF-8 \
	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)bin/monkeybrains.jar" \
	-o bin/$(appName).prg \
	-f monkey.jungle \
	-y $(PRIVATE_KEY) \
	-d $(DEVICE)_sim \
	-w -l 0 

info:
	$(info info:  ${})
	$(info pkey: ${PRIVATE_KEY})
	$(info sdk:  ${SDK_HOME})
	$(info :  ${})

connect: #build
	$(info run shell script to start sim)
	@$(shell ./script/sim.sh ${SDK_HOME} sim)

resim: killmonkeydo build
	@$(shell ./script/sim.sh ${SDK_HOME} mon ${BIN} ${DEVICE})
	#@$(shell ./script/sim.sh ${SDK_HOME} mon ${PWD}/bin/${appName}.prg ${DEVICE})

sim: build killmonkeydo
	$(info run shell script to start watch)
	$(info ./script/sim.sh ${SDK_HOME} mon ${BIN} ${DEVICE})
	@$(shell ./script/sim.sh ${SDK_HOME} mon ${BIN} ${DEVICE})
	#${SDK_HOME}bin/monkeydo bin/$(appName).prg $(DEVICE) &

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

deploy: build
	@cp bin/$(appName).prg $(DEPLOY)

package:
	@$(JAVA_HOME)/bin/java \
	-Dfile.encoding=UTF-8 \
  	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)/bin/monkeybrains.jar" \
  	-o dist/v$(version)/$(appName)-v$(version).iq \
	-e \
	-w \
	-y $(PRIVATE_KEY) \
	-r \
	-f monkey.jungle

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
# packageall: package1 package2 package3

build-debug: info
	@$(JAVA_HOME)/bin/java \
	-Xms1g \
	-Dfile.encoding=UTF-8 \
	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)bin/monkeybrains.jar" \
	-o bin/$(appName).prg \
	-f monkey.jungle \
	-y $(PRIVATE_KEY) \
	-d $(DEVICE)_sim \
	--debug \
	-w -l 0 
