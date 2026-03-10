from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from user.models import User

class Setflow(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        print("USER:", request.data)

        return Response({
            "username": request.user.name,
            "email": request.user.email
        })

