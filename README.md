# 🏪 GESTORE - Système de Gestion Intégrée pour Commerces

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-5.2.6-092E20?logo=django)](https://www.djangoproject.com)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)](https://www.python.org)
[![License](https://img.shields.io/badge/License-Proprietary-red)]()

Application de gestion complète pour commerces de détail : boutiques, supermarchés, pharmacies. Solution moderne avec backend Django REST et frontend Flutter Desktop multi-plateforme.

---

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Installation](#-installation)
- [Développement](#-développement)
- [Structure du projet](#-structure-du-projet)
- [Roadmap](#-roadmap)
- [Documentation](#-documentation)

---

## 🎯 Vue d'ensemble

**GESTORE** est une solution logicielle complète et modulaire permettant la gestion opérationnelle efficace de tout type de commerce de détail.

### Objectifs

- ✅ **Polyvalence** : Adaptation automatique au type de commerce
- ✅ **Performance** : Gestion fluide de gros volumes de données
- ✅ **Sécurité** : Protection des données et traçabilité complète
- ✅ **Mode Offline** : Fonctionnement autonome sans connexion
- ✅ **Multi-plateforme** : Windows, macOS, Linux

---

## 🚀 Fonctionnalités

### ✅ Phase 1 - TERMINÉE (100%)

#### Authentification & Sécurité
- [x] Authentification JWT avec refresh token automatique
- [x] Gestion des utilisateurs avec rôles et permissions granulaires
- [x] Système d'audit trail complet
- [x] Sessions multiples avec tracking IP et géolocalisation
- [x] Verrouillage automatique après tentatives échouées

### ✅ Phase 2 - EN COURS (80%)

#### Backend API
- [x] **Module Inventory** - Gestion complète des stocks
  - Articles avec variantes et catégories
  - Gestion multi-entrepôts
  - Mouvements de stock (FIFO/LIFO)
  - Alertes automatiques (stock bas, expiration)
  - Import/export CSV
- [x] **Module Sales** - Point de vente (POS)
  - Workflow de vente complet
  - Gestion clients et programme fidélité
  - Remises et promotions automatiques
  - Multi-paiements
  - Annulation et retours
- [x] Performance < 50ms sur tous les endpoints
- [x] 150+ endpoints API documentés (Swagger)
- [x] Tests automatisés (>85% coverage)

#### Frontend Flutter Desktop
- [x] Configuration projet multi-plateforme
- [x] Architecture Clean (data/domain/presentation)
- [x] Client API avec Dio et gestion JWT
- [x] Injection de dépendances (GetIt/Injectable)
- [x] State management (Riverpod)
- [x] Splash screen
- [ ] Écran de login et authentification
- [ ] Dashboard principal
- [ ] Interface Inventory
- [ ] Interface POS
- [ ] Mode offline avec synchronisation

### 📋 Phase 3 - PRÉVU

#### Modules Spécialisés
- [ ] GESTORE Pharma (conformité réglementaire)
- [ ] GESTORE Supermarché (gestion DLC/DLUO)
- [ ] GESTORE Mode (variantes et saisonnalité)
- [ ] Module Suppliers (fournisseurs et achats)
- [ ] Module Reporting (analytics et tableaux de bord)

#### Réseau Local
- [ ] Serveur local autonome
- [ ] Synchronisation multi-postes (jusqu'à 10)
- [ ] Réplication haute disponibilité

---

## 🏗️ Architecture

### Architecture Globale

```
┌─────────────────────────────────────────────────────────┐
│                   ARCHITECTURE GESTORE                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────┐         ┌─────────────────┐        │
│  │  FLUTTER APP    │◄───────►│  DJANGO BACKEND │        │
│  │   (Desktop)     │  REST   │   (API REST)    │        │
│  │                 │   API   │                 │        │
│  │ ┌─────────────┐ │         │ ┌─────────────┐ │        │
│  │ │SQLite Local │ │◄────────►│ │ PostgreSQL │ │        │
│  │ │  (Offline)  │ │  Sync   │ │ (Principal) │ │        │
│  │ └─────────────┘ │         │ └─────────────┘ │        │
│  └─────────────────┘         └─────────────────┘        │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### Backend - Django REST Framework

- **Architecture modulaire** : 8 apps Django indépendantes
- **API RESTful** : 150+ endpoints documentés
- **Base de données** : PostgreSQL + Redis (cache)
- **Authentification** : JWT avec rotation des tokens
- **Permissions** : Granulaires par module et action

### Frontend - Flutter Desktop (Clean Architecture)

```
lib/
├── core/                 # Infrastructure commune
│   ├── constants/        # Constantes et endpoints API
│   ├── network/          # Client API (Dio)
│   ├── database/         # Base locale (Drift/SQLite)
│   └── errors/           # Gestion des erreurs
├── features/             # Fonctionnalités par module
│   ├── authentication/
│   │   ├── data/        # Models, DataSources, Repositories
│   │   ├── domain/      # Entities, Use Cases
│   │   └── presentation/ # Screens, Widgets, Providers
│   ├── inventory/
│   └── sales/
└── shared/              # Composants partagés
```

---

## 💻 Technologies

### Backend
- **Django 5.2.6** - Framework Python
- **Django REST Framework 3.15.2** - API REST
- **PostgreSQL** - Base de données principale
- **Redis** - Cache et sessions
- **JWT** - Authentification
- **Docker** - Conteneurisation

### Frontend
- **Flutter 3.35.4** - Framework UI
- **Dart 3.9.2** - Langage
- **Riverpod** - State management
- **Dio** - Client HTTP
- **GetIt/Injectable** - Injection de dépendances
- **Drift** - Base de données locale (SQLite)
- **GoRouter** - Navigation

---

## 📥 Installation

### Prérequis

- Python 3.12+
- Flutter 3.35.4+
- PostgreSQL 14+
- Redis 7+
- Git

### Backend Django

```bash
# Cloner le repo
git clone https://github.com/YOUR_USERNAME/gestore_project.git
cd gestore_project/gestore_backend

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Copier et configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos paramètres

# Migrer la base de données
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Lancer le serveur
python manage.py runserver
```

L'API sera disponible sur : http://localhost:8000/api/

Documentation Swagger : http://localhost:8000/api/docs/

### Frontend Flutter Desktop

```bash
# Aller dans le dossier frontend
cd ../gestore_desktop

# Installer les dépendances
flutter pub get

# Lancer l'application (Windows)
flutter run -d windows

# Ou macOS
flutter run -d macos

# Ou Linux
flutter run -d linux
```

---

## 🔧 Développement

### Backend

```bash
# Lancer les tests
python manage.py test

# Avec couverture
pytest --cov=apps

# Lancer avec Docker
docker-compose up -d

# Créer une migration
python manage.py makemigrations

# Appliquer les migrations
python manage.py migrate
```

### Frontend

```bash
# Hot reload
flutter run -d windows
# Puis appuyez sur 'r' pour recharger

# Lancer les tests
flutter test

# Générer le code (serialization, DI, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Build release
flutter build windows --release
```

### Analyse de code

```bash
# Backend
flake8 .
pylint apps/

# Frontend
flutter analyze
```

---

## 📁 Structure du projet

```
gestore_project/
├── gestore_backend/          # Backend Django
│   ├── apps/
│   │   ├── core/            # ✅ Fonctionnalités communes
│   │   ├── authentication/  # ✅ Gestion utilisateurs
│   │   ├── inventory/       # ✅ Gestion stocks
│   │   ├── sales/           # ✅ Point de vente
│   │   ├── suppliers/       # 📋 À développer
│   │   ├── reporting/       # 📋 À développer
│   │   ├── sync/           # 📋 À développer
│   │   └── licensing/      # 📋 À développer
│   ├── gestore/            # Configuration Django
│   ├── requirements.txt
│   └── manage.py
│
└── gestore_desktop/         # Frontend Flutter
    ├── lib/
    │   ├── config/         # Configuration
    │   ├── core/           # Infrastructure
    │   ├── features/       # Fonctionnalités
    │   └── shared/         # Partagé
    ├── assets/
    ├── test/
    └── pubspec.yaml
```

---

## 🗓️ Roadmap

### Q1 2026
- [x] Backend Authentication (Janvier)
- [x] Backend Inventory & Sales (Janvier-Février)
- [ ] Flutter Desktop base (Février)
- [ ] Authentification Flutter (Février)
- [ ] Interface Inventory & POS (Mars)
- [ ] Synchronisation offline (Mars)

### Q2 2026
- [ ] Modules spécialisés (Pharma, Supermarché)
- [ ] Module Suppliers
- [ ] Module Reporting
- [ ] Mode réseau local

### Q3 2026
- [ ] Système de licensing
- [ ] Installeurs multi-plateformes
- [ ] Tests end-to-end complets
- [ ] Documentation utilisateur

### Q4 2026
- [ ] Version 1.0 Production
- [ ] Support commercial
- [ ] Formation utilisateurs

---

## 📚 Documentation

### API Backend
- **Swagger UI** : http://localhost:8000/api/docs/
- **ReDoc** : http://localhost:8000/api/redoc/
- **OpenAPI Schema** : http://localhost:8000/api/schema/

### Guides
- [Guide d'installation Backend](gestore_backend/README.md)
- [Guide d'installation Frontend](gestore_desktop/README.md)
- [Architecture détaillée](docs/ARCHITECTURE.md) *(à venir)*
- [Guide de contribution](docs/CONTRIBUTING.md) *(à venir)*
- [Changelog](docs/CHANGELOG.md) *(à venir)*

---

## 🧪 Tests

### Backend
- **Tests unitaires** : 150+ tests
- **Couverture** : >85%
- **Framework** : pytest + Django TestCase

### Frontend
- **Tests unitaires** : En cours
- **Tests widgets** : En cours
- **Tests d'intégration** : Planifiés

---

## 📊 Statistiques du projet

- **Backend** : 60+ modèles, 150+ endpoints
- **Frontend** : Architecture Clean complète
- **Lignes de code** : ~15,000+ (backend + frontend)
- **Tests** : >100 tests automatisés
- **Performance API** : <50ms moyenne

---

## 👥 Équipe

- **Lead Backend** : [À définir]
- **Lead Frontend** : [À définir]
- **Chef de Projet** : [À définir]

---

## 📄 Licence

Propriétaire - GESTORE © 2025. Tous droits réservés.

---

## 📞 Contact

- **Email** : hirammandela1@gmail.com
- **Documentation** : https://docs.gestore.com
- **Issues** : https://github.com/Hiram-mandela/gestore_project/issues

---

## 🙏 Remerciements

Merci à tous les contributeurs et aux communautés Django et Flutter pour leurs frameworks exceptionnels.

---

**Développé avec ❤️ par l'équipe GESTORE**