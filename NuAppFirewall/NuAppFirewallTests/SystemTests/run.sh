#!/bin/bash

# Caminho absoluto para o diretório onde os arquivos Swift estão localizados
SYSTEM_TEST_DIR="$(dirname "$0")"

# Lista de arquivos Swift a serem executados
files=(
    "ANSIColor.swift"
    "Network.swift"
    "SystemTestUtils.swift"
    "Loader.swift"
    "Logger.swift"
    "URLReport.swift"
    "SystemTest.swift"
)

# Concatena todos os arquivos em um único arquivo temporário
temp_file=$(mktemp)
for file in "${files[@]}"; do
    # Adiciona o caminho absoluto do arquivo para evitar problemas com diretórios
    cat "$SYSTEM_TEST_DIR/$file" >> "$temp_file"
done

# Executa o arquivo temporário com o Swift
swift "$temp_file" "$SYSTEM_TEST_DIR/controlled-rules.json"

# Remove o arquivo temporário
rm "$temp_file"
