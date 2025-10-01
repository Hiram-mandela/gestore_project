#!/usr/bin/env python3
"""
Script de correction ciblé pour les erreurs authentication restantes
Basé sur les logs d'erreur spécifiques
"""

import os
import re

def apply_targeted_fixes():
    """
    Applique les corrections ciblées pour les erreurs spécifiques
    """
    
    # ================================
    # 1. CORRIGER apps/authentication/views.py
    # ================================
    
    views_file = 'apps/authentication/views.py'
    print(f"🔧 Correction de {views_file}...")
    
    with open(views_file, 'r', encoding='utf-8') as f:
        views_content = f.read()
    
    # Fix 1: RoleViewSet - users_count annotation
    views_content = re.sub(
        r"users_count=Count\('user',\s*filter=Q\(user__is_active=True\)\)",
        "users_count=Count('users', filter=Q(users__is_active=True))",
        views_content
    )
    
    # Fix 2: UserViewSet - Prefetch 'usersession' → 'sessions'
    views_content = re.sub(
        r"Prefetch\(\s*['\"]usersession['\"],",
        "Prefetch(\n                'sessions',",
        views_content
    )
    
    # Fix 3: UserViewSet - Count annotation
    views_content = re.sub(
        r"_is_online=Count\(['\"]usersession['\"],\s*filter=Q\(\s*usersession__",
        "_is_online=Count('sessions', filter=Q(\n                sessions__",
        views_content
    )
    
    # Fix 4: optimize_detail_queryset - prefetch_related
    views_content = re.sub(
        r"\.prefetch_related\(\s*['\"]usersession['\"],",
        ".prefetch_related(\n            'sessions',",
        views_content
    )
    
    # Fix 5: Toutes les autres références 'usersession' restantes
    views_content = re.sub(r"'usersession'", "'sessions'", views_content)
    views_content = re.sub(r'"usersession"', "'sessions'", views_content)
    
    with open(views_file, 'w', encoding='utf-8') as f:
        f.write(views_content)
    
    print(f"✅ {views_file} corrigé")
    
    # ================================
    # 2. CORRIGER apps/authentication/serializers.py
    # ================================
    
    serializers_file = 'apps/authentication/serializers.py'
    print(f"🔧 Correction de {serializers_file}...")
    
    with open(serializers_file, 'r', encoding='utf-8') as f:
        serializers_content = f.read()
    
    # Fix 1: UserSerializer.get_is_online - obj.usersession → obj.sessions
    serializers_content = re.sub(
        r"return obj\.usersession\.filter\(",
        "return obj.sessions.filter(",
        serializers_content
    )
    
    # Fix 2: UserListSerializer.get_is_online - CombinedExpression fix
    # Remplacer la méthode complète pour éviter l'erreur CombinedExpression
    old_get_is_online = r"""def get_is_online\(self, obj\):
        # Version optimisée avec préfetch
        if hasattr\(obj, '_is_online'\):
            return obj\._is_online
        return False"""
    
    new_get_is_online = """def get_is_online(self, obj):
        # Version optimisée avec préfetch
        if hasattr(obj, '_is_online'):
            return obj._is_online > 0  # Count retourne un nombre
        return False"""
    
    serializers_content = re.sub(old_get_is_online, new_get_is_online, serializers_content, flags=re.DOTALL)
    
    # Fix 3: RoleSerializer.get_users_count - obj.user_set → obj.users
    serializers_content = re.sub(
        r"return obj\.user_set\.filter\(is_active=True\)\.count\(\)",
        "return obj.users.filter(is_active=True).count()",
        serializers_content
    )
    
    with open(serializers_file, 'w', encoding='utf-8') as f:
        f.write(serializers_content)
    
    print(f"✅ {serializers_file} corrigé")

def verify_corrections():
    """
    Vérifie que les corrections ont été appliquées
    """
    print("\n🔍 Vérification des corrections...")
    
    # Vérifier views.py
    with open('apps/authentication/views.py', 'r') as f:
        views_content = f.read()
    
    if 'usersession' in views_content:
        print("⚠️ Encore des références 'usersession' dans views.py")
        return False
    
    if "Count('user'" in views_content:
        print("⚠️ Encore des références Count('user') dans views.py")
        return False
    
    # Vérifier serializers.py  
    with open('apps/authentication/serializers.py', 'r') as f:
        serializers_content = f.read()
    
    if 'obj.usersession' in serializers_content:
        print("⚠️ Encore des références obj.usersession dans serializers.py")
        return False
    
    if 'obj.user_set' in serializers_content:
        print("⚠️ Encore des références obj.user_set dans serializers.py")
        return False
    
    print("✅ Toutes les corrections vérifiées avec succès!")
    return True

def main():
    """
    Script principal de correction
    """
    print("🔧 Démarrage des corrections ciblées authentication...")
    
    # Vérifier qu'on est dans le bon répertoire
    if not os.path.exists('apps/authentication'):
        print("❌ Erreur: Exécuter depuis gestore_backend/")
        return
    
    try:
        apply_targeted_fixes()
        
        if verify_corrections():
            print("\n✅ Toutes les corrections appliquées avec succès!")
            print("\n🧪 Relancez maintenant les tests:")
            print("   python manage.py test apps.authentication")
        else:
            print("\n⚠️ Des corrections n'ont pas été appliquées correctement")
        
    except Exception as e:
        print(f"❌ Erreur lors des corrections: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()