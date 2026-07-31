#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="/home/volker/minecraftmod1313/mods"
MINECRAFT_DIR="/var/opt/minecraft/crafty/crafty-4/servers/7834d600-e5ff-4fe2-b44a-bb8569b3ca8d"
BRANCH="main"
LOG_FILE="/var/log/minecraft-deploy.log"

{
    echo "========================================"
    echo "Comprobando cambios: $(date)"

    cd "$REPO_DIR"

    git fetch origin "$BRANCH"

    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse "origin/$BRANCH")

    if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
        echo "No hay cambios nuevos."
        exit 0
    fi

    echo "Cambio detectado:"
    echo "$LOCAL_COMMIT -> $REMOTE_COMMIT"

    # Deja la copia local exactamente igual que GitHub.
    git reset --hard "origin/$BRANCH"

    # Copia los archivos hacia Minecraft.
    rsync -av \
        --exclude=".git/" \
        --exclude=".github/" \
        --exclude="README.md" \
        "$REPO_DIR/" "$MINECRAFT_DIR/"

    # Cambia este usuario por el que ejecuta Crafty/Minecraft.
    chown -R crafty:crafty "$MINECRAFT_DIR"

    echo "Despliegue completado: $(date)"

} >> "$LOG_FILE" 2>&1