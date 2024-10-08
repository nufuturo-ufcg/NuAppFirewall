# Define variáveis para os diretórios e o nome do aplicativo
APP_NAME = NuAppFirewall
APP_DIR = /Applications
PROJECT_DIR = ./NuAppFirewall
BUILD_DIR = /Users/ec2-user/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*/Build/Products/Debug

.PHONY: all clean build install removeApp run

# Define a regra padrão
all: run

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

#Ativar a extensão
activate:
	@$(APP_DIR)/$(APP_NAME).app/Contents/MacOS/$(APP_NAME) activate

# Executar o app
run: removeApp clean build install activate 
