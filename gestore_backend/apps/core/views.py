# apps/core/views.py
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings

@api_view(['GET'])
@permission_classes([AllowAny])  # Pas d'authentification requise pour health check
def health_check(request):
    """
    Endpoint de health check pour tester la connectivité
    Utilisé par le frontend pour valider les connexions
    """
    return Response({
        'status': 'healthy',
        'service': 'GESTORE API',
        'version': '1.0.0',
        'mode': settings.ENVIRONMENT_MODE if hasattr(settings, 'ENVIRONMENT_MODE') else 'unknown',
    }, status=status.HTTP_200_OK)