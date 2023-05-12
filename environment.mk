# Garmin connect iq env
SDK_HOME = $(shell cat ~/.Garmin/ConnectIQ/current-sdk.cfg)
DEPLOY ?= ~/src/grolba/iq/
#PRIVATE_KEY=~/tmp/g-dev-key
PRIVATE_KEY=~/tmp/grsa.der
#PRIVATE_KEY = ~/.ssh/garmin-dev-key
JAVA_HOME  ?= /usr/lib/jvm/default
