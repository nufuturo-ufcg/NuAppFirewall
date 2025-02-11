# Define variáveis para os diretórios e o nome do aplicativo
APP_NAME = NuAppFirewall
APP_DIR = /Applications
PROJECT_DIR = ./NuAppFirewall
BUILD_DIR = ~/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*/Build/Products/Debug
SYSTEM_TEST_DIR = ./NuAppFirewall/NuAppFirewallTests/SystemTests
SYSTEM_TEST_FILE = SystemTest.swift
TEST_RULES_FILE = controlled-rules.json
RULES_FILE = rules.json
RULES_DESTINATION = /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/

.PHONY: all clean build install removeApp run help test systemTest setup-xcode copyRules copyRulesFile runAndStop runSystemTests fullSystemTest

# Define a regra padrão
all: run

# Faz a configuração inicial do xcode
setup-xcode:
	@sudo xcode-select --switch /Applications/Xcode.app
	@sudo xcodebuild -license
	@xcodebuild -runFirstLaunch

# Regra para rodar os testes de sistema
systemTest: checkProcess

# Verifica se há logs recentes do processo
checkProcess:
	@echo "Verificando se o processo está ativo..."
	@echo "Aguardando logs da extensão..."
	@log_output=$$(log show --predicate 'subsystem == "com.nufuturo.nuappfirewall.extension"' --info --style compact --last 7s); \
	if echo "$$log_output" | grep -q "CATEGORY"; then \
		echo "Processo já está ativo. Pulando etapas de cópia e inicialização."; \
		$(MAKE) runSystemTests; \
	else \
		echo "Nenhum log recente encontrado. Executando passos completos."; \
		$(MAKE) fullSystemTest; \
	fi

# Executa todos os passos se o processo não estiver ativo
fullSystemTest: copyRules copyRulesFile runAndStop runSystemTests

# Copia o arquivo de regras para o destino
copyRules:
	@echo "Copiando $(SYSTEM_TEST_DIR)/$(TEST_RULES_FILE) para $(RULES_DESTINATION)/$(TEST_RULES_FILE)"
	@sudo cp $(SYSTEM_TEST_DIR)/$(TEST_RULES_FILE) $(RULES_DESTINATION)/$(TEST_RULES_FILE)

# Copia controlled-rules.json como rules.json
copyRulesFile:
	@echo "Substituindo $(TEST_RULES_FILE) por $(RULES_FILE)..."
	@sudo cp $(RULES_DESTINATION)/$(TEST_RULES_FILE) $(RULES_DESTINATION)/$(RULES_FILE)

# Inicia o processo no terminal e aguarda o processo de extensão ser ativado
runAndStop:
	@echo "Iniciando make run em novo terminal..."
	@osascript -e 'tell application "Terminal" to do script "cd $(CURDIR) && make run"'

	@echo "Aguardando logs da extensão..."
	@while true; do \
		if log stream --predicate 'subsystem == "com.nufuturo.nuappfirewall.extension"' --info --style compact | grep -q "Data loaded from JSON"; then \
			echo "Log encontrado. Extensão ativa."; \
			break; \
		fi; \
		sleep 1; \
	done

# Roda o script run.sh para executar os testes do sistema
runSystemTests:
	@echo "Executando testes do sistema..."
	@$(SYSTEM_TEST_DIR)/run.sh

# Roda os testes
test:
	xcodebuild test -project $(PROJECT_DIR)/$(APP_NAME).xcodeproj -scheme $(APP_NAME) -destination 'platform=macOS' -allowProvisioningUpdates -parallel-testing-enabled NO

# Limpar o build do projeto
clean:
	xcodebuild clean -project $(PROJECT_DIR)/$(APP_NAME).xcodeproj -scheme $(APP_NAME)

# Remover a aplicação do Applications caso ela exista
removeApp:
	sudo rm -rf $(APP_DIR)/$(APP_NAME).app

# Construir o projeto
build:
	xcodebuild -project $(PROJECT_DIR)/$(APP_NAME).xcodeproj -scheme $(APP_NAME) -configuration Debug

# Copiar o app para a pasta Applications
install:
	sudo cp -r $(BUILD_DIR)/$(APP_NAME).app $(APP_DIR)

# Ativar a extensão
activate:
	@$(APP_DIR)/$(APP_NAME).app/Contents/MacOS/$(APP_NAME) activate

# Executar o app
run: removeApp clean build install activate

# Mostrar ajuda com a descrição dos comandos
help:
	@echo "Available commands:"
	@echo "  all             - Cleans, builds, installs, and activates the app (default)"
	@echo "  setup-xcode     - Configures Xcode environment, displays license, and runs initial setup"
	@echo "  test            - Runs project tests"
	@echo "  systemTest      - Checks if the process is active and runs system tests"
	@echo "  checkProcess    - Verifies if the extension is running by checking recent logs"
	@echo "  fullSystemTest  - Executes all steps if the process is not active"
	@echo "  copyRules       - Copies controlled-rules.json to the appropriate directory"
	@echo "  copyRulesFile   - Replaces controlled-rules.json as rules.json"
	@echo "  runAndStop      - Starts the extension in a new terminal and waits for activation"
	@echo "  runSystemTests  - Executes the system tests script"
	@echo "  clean           - Cleans the project build"
	@echo "  removeApp       - Removes the app from the Applications folder"
	@echo "  build           - Builds the project"
	@echo "  install         - Installs the app in the Applications folder"
	@echo "  activate        - Activates the app extension"
	@echo "  run             - Removes, cleans, builds, installs, and activates the app"
	@echo "  help            - Displays this help message"
