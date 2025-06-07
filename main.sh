#!/bin/bash

# Скрипт автоматизации переноса и сборки проекта azteroids с подготовкой GitHub Actions, публикацией пакетов и инструкцией для пользователя

# 1. Клонирование оригинального репозитория и создание нового
# --- Замените следующие переменные на свои данные! ---
NEW_REPO_OWNER="yakudza992683" # ваше имя пользователя GitHub
NEW_REPO_NAME="azteroids"      # имя нового репозитория
GITHUB_TOKEN="your_github_token_here" # ваш GitHub Token с правами push и создания репозиториев

# 1. Клонирование оригинального проекта
git clone https://github.com/rodrigosetti/azteroids.git
cd azteroids

# 2. Создание нового репозитория на GitHub через API (или вручную, если не хотите скриптовать)
curl -H "Authorization: token ${GITHUB_TOKEN}" \
     -d "{\"name\": \"${NEW_REPO_NAME}\", \"private\": false}" \
     https://api.github.com/user/repos

# 3. Перенастройка git и пуш в новый репозиторий
git remote remove origin
git remote add origin "https://github.com/${NEW_REPO_OWNER}/${NEW_REPO_NAME}.git"
git push -u origin master

# 4. Создание каталога workflow и добавление скрипта CI для Linux/Windows
mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'EOF'
name: Build azteroids

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build-linux:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        compiler: [clang]
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: sudo apt-get update && sudo apt-get install -y build-essential clang libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev cmake dpkg-dev fakeroot
      - name: Build
        run: |
          CC=clang make
      - name: Package .deb
        run: |
          mkdir -p azteroids-deb/usr/games
          cp azteroids azteroids-deb/usr/games/
          fpm -s dir -t deb -n azteroids -v 1.0 --prefix=/ -C azteroids-deb .
      - uses: actions/upload-artifact@v4
        with:
          name: azteroids-deb
          path: "*.deb"

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install MSYS2 and dependencies
        uses: msys2/setup-msys2@v2
        with:
          update: true
          install: >-
            mingw-w64-x86_64-toolchain
            mingw-w64-x86_64-SDL2
            mingw-w64-x86_64-SDL2_image
            mingw-w64-x86_64-SDL2_mixer
            mingw-w64-x86_64-SDL2_ttf
      - name: Build
        shell: msys2 {0}
        run: |
          make
      - name: Package MSI (using WiX)
        shell: bash
        run: |
          # предполагается, что WiX и NSIS уже установлены
          # или используйте другой способ создать MSI/EXE
          echo "Создание MSI пакета - настройте этот шаг под свои нужды"
      - uses: actions/upload-artifact@v4
        with:
          name: azteroids-msi
          path: "*.msi"
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