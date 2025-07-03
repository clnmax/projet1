🎯 Objectif global :
Mettre en pratique les fondamentaux Linux et les bonnes pratiques de sécurité à travers un audit complet d’un serveur, suivi de son durcissement, l’automatisation de vérifications, et le déploiement d’une application web.
✅ Partie 1 – Exercices préparatoires 
Ces exercices vous aident à explorer votre environnement et à développer les bons réflexes d’observation, de détection de vulnérabilités et d’audit. Vous devez illustrer chaque réponse avec les commandes utilisées et fournir un mini-compte rendu clair.

🔍 Exercice 1 : Reconnaissance de l’environnement
Lancez votre machine Linux (VM locale, cloud, ou conteneur selon les consignes du formateur).

Répondez aux questions suivantes :
1. Quelle est la version du noyau Linux utilisée ? (Pensez à expliquer l’impact potentiel d’un noyau obsolète ou vulnérable.)
2. Quels services de sécurité sont actifs ? (Exemples : firewall, SELinux, AppArmor – sont-ils activés et en mode enforcement ?)
3. Quels ports sont actuellement ouverts ?
○ Quelles sont les commandes permettant de les détecter ?
○ Y a-t-il des ports ouverts non justifiés ? (Quels risques peuvent-ils représenter ?)

🔍Exercice 2 : Recherche de fichiers et analyse de logs
1. Rechercher tous les fichiers contenant des secrets potentiels Mots-clés à rechercher sans tenir compte de la casse : password, api_key, token, secret_key. (Décrivez votre stratégie de recherche : où chercher ? Avec quels outils ?)
2. Analyser les logs d’authentification
○ Trouvez les tentatives de connexion échouées.
○ Quels fichiers de logs consulter ?
○ Quels mots-clés utiliser pour détecter les échecs ? (Ex. : “failed”, “invalid”, etc.)
3. Lister les fichiers récemment modifiés dans /etc
○ Pourquoi ce dossier est-il critique ?
○ Quelles modifications doivent éveiller votre vigilance ?

🔐 Exercice 3 : Analyse des permissions sensibles
1. Quels sont les groupes à privilèges sur votre système ?
○ Quels utilisateurs en font partie ?
○ Y a-t-il des utilisateurs ayant un accès root implicite ou explicite ?
2. Quels utilisateurs ont accès à un shell de connexion ? (Différencier les utilisateurs humains des comptes de service.)

🚀 Partie 2 – Mini-Projet (2h)
Tâches à réaliser
🔎 1. Audit initial 
● Collecte des informations système (OS, kernel, services)
● Vérification des utilisateurs, groupes, permissions sensibles
● État des services en cours (sont-ils nécessaires ?)
● Identification des anomalies ou failles potentielles

2. Corrections et durcissement
● Désactiver les services non essentiels
● Corriger les permissions trop larges
● Sécuriser les fichiers de configuration (SSH, sudoers, etc.)
● Vérifier et renforcer la configuration SSH (port, root login, authentification par clé)

⚙️3. Script d’audit automatisé – 
Créer un script Bash avec les fonctionnalités suivantes :
● Détection des fichiers SUID/SGID
● Liste des permissions critiques (ex. : fichiers world-writable)
● Liste des utilisateurs à risque (ex. : root shells, no password)
● Liste des services actifs
● Génération d’un rapport daté (/var/log/audit-YYYYMMDD.log)
● Programmation automatique du script via cron à 03h00 chaque jour

🌐 4. Déploiement application web 
● Installer nginx
● Configurer le serveur pour faire tourner l’application sur le port 8080
●Vérifier le bon fonctionnement local via curl ou navigateur
● Bonus : restreindre l’accès à certaines IPs ou mettre en place une authentification simple

📝 5. Documentation 
● Documenter l’état initial du système
● Lister les problèmes identifiés et leurs impacts
● Détaillez les mesures correctives prises
● Proposer des recommandations supplémentaires pour renforcer la sécurité
🎓 Livrables attendus :
1. Compte rendu des exercices 1 à 3 (avec commandes utilisées)
2. Script Bash documenté (script_compliance.sh)
3. Rapport d’audit automatisé généré (report_activity.pdf)

