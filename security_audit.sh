#!/bin/bash


# --- Variables de configuration ---
LOG_DIR="/var/log"
REPORT_DATE=$(date +%Y%m%d)
REPORT_FILE="${LOG_DIR}/audit-${REPORT_DATE}.log"


# Fonction pour ajouter un titre et du contenu au rapport
log_section() {
    echo -e "\n\n--- $1 ---\n" >> "$REPORT_FILE"
    echo "$2" >> "$REPORT_FILE"
}

# 1. Détection des fichiers SUID/SGID
check_suid_sgid() {
    echo "Recherche des fichiers SUID/SGID (cela peut prendre un certain temps)..."
    local output
    output=$(find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld {} \; 2>/dev/null)
    if [ -n "$output" ]; then
        log_section "Fichiers SUID/SGID trouvés" "$output"
    else
        log_section "Fichiers SUID/SGID trouvés" "Aucun fichier SUID/SGID anormal détecté."
    fi
}
