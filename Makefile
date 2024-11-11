# Define variáveis para os diretórios e o nome do aplicativo
APP_NAME = NuAppFirewall
APP_DIR = /Applications
PROJECT_DIR = ./NuAppFirewall
BUILD_DIR = ~/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*/Build/Products/Debug
SYSTEM_TEST_DIR = ./NuAppFirewall/NuAppFirewallTests/SystemTests
SYSTEM_TEST_FILE = SystemTest.swift
TEST_RULES_FILE = controlled-rules.json

.PHONY: all clean build install removeApp run help test systemTests setup-xcode

# Define a regra padrão
all: run

# Faz a configuração inicial do xcode
setup-xcode:
	@sudo xcode-select --switch /Applications/Xcode.app
	@sudo xcodebuild -license
	@xcodebuild -runFirstLaunch

# Roda os testes do sistema
systemTest:
	swift $(SYSTEM_TEST_DIR)/$(SYSTEM_TEST_FILE) $(SYSTEM_TEST_DIR)/$(TEST_RULES_FILE)

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
	@echo "  all          - Cleans, builds, installs, and activates the app (default)"
	@echo "  setup-xcode  - Configures Xcode environment, displays license, and runs initial setup"
	@echo "  test         - Runs project tests"
	@echo "  systemTest   - Runs system tests using SystemTest.swift with the rules from controlled-rules.json"
	@echo "  clean        - Cleans the project build"
	@echo "  removeApp    - Removes the app from the Applications folder"
	@echo "  build        - Builds the project"
	@echo "  install      - Installs the app in the Applications folder"
	@echo "  activate     - Activates the app extension"
	@echo "  run          - Removes, cleans, builds, installs, and activates the app"
	@echo "  help         - Displays this help message"
