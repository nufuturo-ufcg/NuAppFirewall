#Remove a aplicação do Applications caso ela exista
cd /Applications

sudo rm -rf NuAppFirewall.app

# Mudar para o diretório do build
cd /Users/ec2-user/Library/Developer/Xcode/DerivedData/NuAppFirewall-*/Build/Products/Debug

# Copiar o app para a pasta Applications
sudo cp -r NuAppFirewall.app /Applications

# Mover para o diretório Applications e executar o app
cd /Applications
./NuAppFirewall.app/Contents/MacOS/NuAppFirewall activate
