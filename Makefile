# Comandos de la app. Todos pasan el .env con --dart-define-from-file.
#
#   make run-android                 # primer emulador o dispositivo Android
#   make run-ios MODE=release        # primer simulador o iPhone
#   make run-ios DEVICE=<id>         # un dispositivo puntual (ver `make devices`)
#   make build-android               # APK de release
#
# Variables: MODE (debug | profile | release), DEVICE, ENV_FILE (.env) y
# FLUTTER (flutter; por ejemplo FLUTTER="fvm flutter").

FLUTTER ?= flutter
ENV_FILE ?= .env
MODE ?=
DEVICE ?=

# Claves sin las que la app no arranca (ver AppConfig.missingKeys).
REQUIRED_KEYS := ELDORADO_API_URL CRIPTOYA_API_URL

DEFINES := --dart-define-from-file=$(ENV_FILE)
RUN_MODE := $(if $(MODE),--$(MODE),)
BUILD_MODE := --$(if $(MODE),$(MODE),release)

.DEFAULT_GOAL := help
.PHONY: help check-env devices run-android run-ios build-android \
	build-android-bundle build-ios build-ipa

help: ## Lista los comandos
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-22s %s\n", $$1, $$2}'

check-env: ## Verifica que el .env exista y tenga las claves obligatorias
	@test -f $(ENV_FILE) || { \
		echo "Falta $(ENV_FILE): copia .env.example a $(ENV_FILE) y completa los valores."; \
		exit 1; }
	@for key in $(REQUIRED_KEYS); do \
		grep -Eq "^$$key=.+" $(ENV_FILE) || { \
			echo "Falta $$key en $(ENV_FILE) (ver .env.example)."; exit 1; }; \
	done

devices: ## Lista los dispositivos conectados
	@$(FLUTTER) devices

# $(1): plataforma (android | ios); $(2): nombre para el mensaje de error.
define run_on
	@device="$(DEVICE)"; \
	if [ -z "$$device" ]; then \
		device=$$(FLUTTER="$(FLUTTER)" sh tool/device_id.sh $(1)); \
	fi; \
	if [ -z "$$device" ]; then \
		echo "No hay un dispositivo $(2) conectado: abre uno o pasa DEVICE=<id> (make devices)."; \
		exit 1; \
	fi; \
	echo "$(FLUTTER) run -d $$device $(RUN_MODE) $(DEFINES)"; \
	$(FLUTTER) run -d "$$device" $(RUN_MODE) $(DEFINES)
endef

run-android: check-env ## flutter run en Android (MODE, DEVICE)
	$(call run_on,android,Android)

run-ios: check-env ## flutter run en iOS (MODE, DEVICE)
	$(call run_on,ios,iOS)

build-android: check-env ## APK (release por defecto; MODE)
	$(FLUTTER) build apk $(BUILD_MODE) $(DEFINES)

build-android-bundle: check-env ## App bundle (.aab) para Google Play
	$(FLUTTER) build appbundle $(BUILD_MODE) $(DEFINES)

build-ios: check-env ## App de iOS sin firmar (verifica que compila)
	$(FLUTTER) build ios $(BUILD_MODE) --no-codesign $(DEFINES)

build-ipa: check-env ## IPA firmada para distribución (necesita el equipo de firma)
	$(FLUTTER) build ipa $(BUILD_MODE) $(DEFINES)
