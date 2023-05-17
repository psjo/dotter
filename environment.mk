# Garmin connect iq env
SDK_HOME = $(shell cat ~/.Garmin/ConnectIQ/current-sdk.cfg)
DEPLOY ?= ~/src/grolba/iq/
PRIVATE_KEY ?= ${DEPLOY}grsa.der
JAVA_HOME  ?= /usr/lib/jvm/default
