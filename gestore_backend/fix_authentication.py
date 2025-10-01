#!/usr/bin/env python3
"""
Script de correction complète pour les erreurs authentication
À exécuter depuis gestore_backend/

Corrige toutes les erreurs identifiées dans les tests
"""

import os
import re

def fix_serializers():
    """Corriger les relations dans apps/authentication/serializers.py"""
    
    file_path = 'apps/authentication/serializers.py'
    
    # Lire le fichier
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Correction 1: get_users_count dans RoleSerializer
    content = re.sub(
        r'return obj\.user_set\.filter\(is_active=True\)\.count\(\)',
        'return obj.users.filter(is_active=True).count()',
        content
    )
    
    # Correction 2: get_is_online dans UserSerializer
    content = re.sub(
        r'return obj\.usersession\.filter\(',
        'return obj.sessions.filter(',
        content
    )
    
    # Sauvegarder
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Serializers corrigés")


def fix_views():
    """Corriger les annotations dans apps/authentication/views.py"""
    
    file_path = 'apps/authentication/views.py'
    
    # Lire le fichier
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Correction 1: annotation users_count dans RoleViewSet
    content = re.sub(
        r"users_count=Count\('user', filter=Q\(user__is_active=True\)\)",
        "users_count=Count('users', filter=Q(users__is_active=True))",
        content
    )
    
    # Correction 2: préfetch usersession -> sessions
    content = re.sub(
        r"'usersession',",
        "'sessions',",
        content
    )
    
    # Correction 3: annotation _is_online 
    content = re.sub(
        r"_is_online=Count\('usersession', filter=Q\(\s*usersession__is_active=True,\s*usersession__login_at__gte=",
        "_is_online=Count('sessions', filter=Q(\n                sessions__is_active=True,\n                sessions__login_at__gte=",
        content
    )
    
    # Correction 4: Prefetch usersession dans optimize_list_queryset
    content = re.sub(
        r"Prefetch\(\s*'usersession',",
        "Prefetch(\n                'sessions',",
        content
    )
    
    # Sauvegarder
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Views corrigées")


def fix_tests():
    """Corriger le test de validation dans apps/authentication/tests.py"""
    
    file_path = 'apps/authentication/tests.py'
    
    # Lire le fichier
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Trouver et remplacer la méthode test_user_validation
    test_method = '''    def test_user_validation(self):
        """Test validation utilisateur"""
        
        # Test avec données invalides pour générer erreurs email ET password
        invalid_data = {
            'username': 'testuser',
            'email': '',  # Email vide pour générer erreur email
            'first_name': 'Test',
            'last_name': 'User',
            'password': 'test123',
            'password_confirm': 'different123',  # Mots de passe différents
            'role_id': str(self.role.id)
        }
        
        serializer = UserCreateSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        
        # Vérifier que les deux erreurs sont présentes
        self.assertIn('email', serializer.errors)
        self.assertIn('password_confirm', serializer.errors)'''
    
    # Remplacer la méthode existante
    content = re.sub(
        r'def test_user_validation\(self\):.*?self\.assertIn\(\'email\', serializer\.errors\)',
        test_method,
        content,
        flags=re.DOTALL
    )
    
    # Sauvegarder
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Tests corrigés")


def main():
    """Exécuter toutes les corrections"""
    
    print("🔧 Démarrage des corrections authentication...")
    
    # Vérifier qu'on est dans le bon répertoire
    if not os.path.exists('apps/authentication'):
        print("❌ Erreur: Exécuter depuis gestore_backend/")
        return
    
    try:
        fix_serializers()
        fix_views() 
        fix_tests()
        
        print("\n✅ Toutes les corrections appliquées avec succès!")
        print("\n🧪 Vous pouvez maintenant relancer les tests:")
        print("   python manage.py test apps.authentication")
        
    except Exception as e:
        print(f"❌ Erreur lors des corrections: {e}")


if __name__ == '__main__':
    main()