#!/bin/bash

# Programmation: Ajouter à cron pour exécution quotidienne à 02h00.

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

# 2. Liste des permissions critiques (fichiers world-writable)
check_world_writable() {
    echo "Recherche des fichiers et répertoires World-Writable (cela peut prendre un certain temps)..."
    local output_files
    output_files=$(find / -type f -perm -o+w -exec ls -ld {} \; 2>/dev/null)
    local output_dirs_no_sticky
    output_dirs_no_sticky=$(find / -type d -perm -o+w ! -perm -o+t -exec ls -ld {} \; 2>/dev/null)

    if [ -n "$output_files" ] || [ -n "$output_dirs_no_sticky" ]; then
        if [ -n "$output_files" ]; then
            log_section "Fichiers World-Writable" "$output_files"
        fi
        if [ -n "$output_dirs_no_sticky" ]; then
            log_section "Répertoires World-Writable SANS Sticky Bit" "$output_dirs_no_sticky"
        fi
    else
        log_section "Permissions Critiques (World-Writable)" "Aucun fichier ou répertoire World-Writable sans sticky bit anormal détecté."
    fi
}

# 3. Liste des utilisateurs à risque
check_risky_users() {
    echo "Vérification des utilisateurs à risque..."
    local output=""

    # 3.1 Utilisateurs avec UID 0 (root shells)
    ROOT_UID_USERS=$(awk -F: '($3 == "0" && $1 != "root") { print $1 }' /etc/passwd)
    if [ -n "$ROOT_UID_USERS" ]; then
        output+="--- Utilisateurs avec UID 0 (outre root) ---\n"
        output+="$ROOT_UID_USERS\n\n"
    fi

    # 3.2 Utilisateurs sans mot de passe
    NO_PASSWORD_USERS=$(awk -F: '($2 == "") { print $1 }' /etc/passwd)
    if [ -n "$NO_PASSWORD_USERS" ]; then
        output+="--- Utilisateurs sans mot de passe ---\n"
        output+="$NO_PASSWORD_USERS\n\n"
    fi

    # 3.3 Users avec accès sudo (via groupe wheel ou entrée directe)
    SUDO_USERS=$(grep -E '^(%wheel|[^#].*ALL=\(ALL\).*ALL)' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -v 'NOPASSWD' | awk '{print $1}' | sed 's/%//g' | sort -u)
    NOPASSWD_SUDO_USERS=$(grep -E '^(%wheel|[^#].*ALL=\(ALL\).*NOPASSWD)' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | awk '{print $1}' | sed 's/%//g' | sort -u)
    
    if [ -n "$SUDO_USERS" ]; then
        output+="--- Utilisateurs/Groupes ayant accès sudo (mot de passe requis) ---\n"
        # Expand group members
        for group_name in $SUDO_USERS; do
            if grep -q "^$group_name:" /etc/group; then
                members=$(grep "^$group_name:" /etc/group | cut -d: -f4)
                if [ -n "$members" ]; then
                    output+="$group_name (membres: $members)\n"
                else
                    output+="$group_name (aucun membre explicitement listé)\n"
                fi
            else
                output+="$group_name (utilisateur individuel)\n"
            fi
        done
        output+="\n"
    fi

    if [ -n "$NOPASSWD_SUDO_USERS" ]; then
        output+="--- Utilisateurs/Groupes ayant accès sudo SANS mot de passe ---\n"
        for group_name in $NOPASSWD_SUDO_USERS; do
            if grep -q "^$group_name:" /etc/group; then
                members=$(grep "^$group_name:" /etc/group | cut -d: -f4)
                if [ -n "$members" ]; then
                    output+="$group_name (membres: $members)\n"
                else
                    output+="$group_name (aucun membre explicitement listé)\n"
                fi
            else
                output+="$group_name (utilisateur individuel)\n"
            fi
        done
        output+="\n"
    fi

    # 3.4 Utilisateurs du groupe docker (accès root implicite)
    DOCKER_GROUP_MEMBERS=$(grep '^docker:' /etc/group | cut -d: -f4)
    if [ -n "$DOCKER_GROUP_MEMBERS" ]; then
        output+="--- Utilisateurs dans le groupe 'docker' (accès root implicite) ---\n"
        output+="$DOCKER_GROUP_MEMBERS\n\n"
    fi

    if [ -n "$output" ]; then
        log_section "Utilisateurs à Risque Potentiel" "$output"
    else
        log_section "Utilisateurs à Risque Potentiel" "Aucun utilisateur à risque critique direct détecté (UID 0, pas de mot de passe, ou sudo NOPASSWD)."
    fi
}

# 4. Liste des services actifs
check_active_services() {
    echo "Collecte des services actifs..."
    local output
    output=$(systemctl list-units --type=service --state=running --no-pager | grep -E '\.service' | awk '{print $1, $3, $4, $5}')
    log_section "Services Actifs (Running)" "$output"
}

# --- Corps principal du script ---

# Vérifier si le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root ou avec sudo."
    exit 1
fi

echo "Début de l'audit de sécurité..."
echo "Rapport généré dans : $REPORT_FILE"

# Créer/Vider le fichier de rapport
echo "Rapport d'Audit de Sécurité - $(date)" > "$REPORT_FILE"
echo "=========================================" >> "$REPORT_FILE"

check_suid_sgid
check_world_writable
check_risky_users
check_active_services

echo "Audit terminé. Vérifiez le fichier : $REPORT_FILE"

 
