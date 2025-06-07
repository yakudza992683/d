#!/bin/bash

# Скрипт автоматизации переноса и сборки проекта azteroids с подготовкой GitHub Actions, публикацией пакетов и инструкцией для пользователя
# Теперь с клонированием glfw и entityx в lib/ и удалением в них .git

# --- Замените следующие переменные на свои данные! ---
NEW_REPO_OWNER="yakudza992683" # ваше имя пользователя GitHub
NEW_REPO_NAME="azteroids"      # имя нового репозитория
GITHUB_TOKEN="your_github_token_here" # ваш GitHub Token с правами push и создания репозиториев

# 1. Клонирование оригинального проекта
git clone --recurse-submodules https://github.com/rodrigosetti/azteroids.git
cd azteroids

# 1.1 Клонирование зависимостей в lib/ и удаление .git
mkdir -p lib

echo "Клонируем glfw..."
git clone https://github.com/glfw/glfw.git lib/glfw
rm -rf lib/glfw/.git

echo "Клонируем entityx..."
git clone https://github.com/alecthomas/entityx.git lib/entityx
rm -rf lib/entityx/.git

# 1.2 Удаляем .git из всех сабмодулей проекта, если они есть
find . -type d -name '.git' ! -path "./.git" -exec rm -rf {} +

# 1.3 (опционально) Удаляем .gitmodules если не нужен
rm -f .gitmodules

# 2. Создание нового репозитория на GitHub через API (или вручную, если не хотите скриптовать)
curl -H "Authorization: token ${GITHUB_TOKEN}" \
     -d "{\"name\": \"${NEW_REPO_NAME}\", \"private\": false}" \
     https://api.github.com/user/repos

# 3. Перенастройка git и пуш в новый репозиторий
git init
git remote add origin "https://github.com/${NEW_REPO_OWNER}/${NEW_REPO_NAME}.git"
git add .
git commit -m "Initial commit: migrate azteroids with glfw and entityx in lib/"
git push -u origin main

# 4. Создание каталога workflow и добавление скрипта CI для Linux/Windows
mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'EOF'
name: Build azteroids

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y clang make libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev dpkg-dev fakeroot ruby ruby-dev gcc
          sudo gem install --no-document fpm
      - name: Build
        run: CC=clang make
      - name: Package .deb
        run: |
          mkdir -p azteroids-deb/usr/games
          cp azteroids azteroids-deb/usr/games/
          fpm -s dir -t deb -n azteroids -v 1.0 --prefix=/ -C azteroids-deb .
      - name: Upload Linux artifact (.deb)
        uses: actions/upload-artifact@v4
        with:
          name: azteroids-deb
          path: ./*.deb

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install MSYS2 and dependencies
        uses: msys2/setup-msys2@v2
        with:
          update: true
          install: >-
            mingw-w64-x86_64-gcc
            mingw-w64-x86_64-make
            mingw-w64-x86_64-SDL2
            mingw-w64-x86_64-SDL2_image
            mingw-w64-x86_64-SDL2_mixer
            mingw-w64-x86_64-SDL2_ttf
      - name: Build with mingw32-make
        shell: msys2 {0}
        run: |
          mingw32-make
      - name: Prepare MSI files
        shell: bash
        run: |
          mkdir -p msi_root
          cp azteroids.exe msi_root/
      - name: Download WiX Toolset
        run: |
          choco install wix --no-progress
      - name: Create MSI installer
        shell: powershell
        run: |
          $wxs = @"
          <Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
            <Product Id='*' Name='azteroids' Language='1033' Version='1.0.0.0' Manufacturer='azteroids authors' UpgradeCode='B1B9E7A0-8B9B-43A3-A9B6-3B7B9C6B7EFA'>
              <Package InstallerVersion='200' Compressed='yes' InstallScope='perMachine' />
              <Directory Id='TARGETDIR' Name='SourceDir'>
                <Directory Id='ProgramFilesFolder'>
                  <Directory Id='INSTALLFOLDER' Name='azteroids'>
                    <Component Id='MainExecutable' Guid='*'>
                      <File Id='azteroidsExe' Name='azteroids.exe' Source='msi_root/azteroids.exe' />
                    </Component>
                  </Directory>
                </Directory>
              </Directory>
              <Feature Id='DefaultFeature' Level='1'>
                <ComponentRef Id='MainExecutable' />
              </Feature>
            </Product>
          </Wix>
          "@
          Set-Content azteroids.wxs $wxs
          & "C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe" azteroids.wxs
          & "C:\Program Files (x86)\WiX Toolset v3.11\bin\light.exe" azteroids.wixobj -o azteroids.msi
      - name: Upload Windows artifact (.msi)
        uses: actions/upload-artifact@v4
        with:
          name: azteroids-msi
          path: azteroids.msi
EOF

# 5. Добавление и коммит workflow
git add .github/workflows/build.yml
git commit -m "Add GitHub Actions workflow for Linux and Windows builds"
git push

# 6. Инструкция по установке пакета и предоставлению скриншота (вывод пользователю)
cat << INST
======================================================
Следующие шаги нужно выполнить вручную:

1. Дождитесь, пока GitHub Actions соберет .deb и .msi пакеты.
2. Скачайте собранные пакеты из вкладки "Actions" -> "Artifacts" вашего репозитория.
3. Для установки на Linux:
   sudo dpkg -i azteroids_1.0_amd64.deb
   azteroids

4. Для установки на Windows:
   Запустите azteroids.msi и следуйте мастеру установки.

5. Запустите игру, сделайте снимок экрана (скриншот) с работающей программой.

6. Для каждого шага делайте скриншот/отчет: 
   - Клон репозитория
   - Создание GitHub-репозитория
   - Настройка и пуш
   - CI/CD билд (скриншот страницы Actions)
   - Скачивание и установка пакета
   - Запуск программы

======================================================
INST

echo "Готово! Следуйте инструкциям выше для завершения работы."