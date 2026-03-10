from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .Serializers import RegisterSerializer, LoginSerializer


class Register(APIView):

    def post(self, request):

        serializer = RegisterSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()

            return Response(
                {"message": "User created"},
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=400)


class Login(APIView):

    def post(self, request):

        serializer = LoginSerializer(data=request.data)

        if serializer.is_valid():

            email = serializer.validated_data["email"]
            password = serializer.validated_data["password"]

            user = User.objects.filter(email=email).first()

            if user is None:
                return Response(
                    {"error": "User not found"},
                    status=status.HTTP_404_NOT_FOUND
                )

            if not check_password(password, user.password):
                return Response(
                    {"error": "Invalid password"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            refresh = RefreshToken.for_user(user)

            return Response({
                "message": "Login successful",
                "refresh": str(refresh),
                "access": str(refresh.access_token)
            })

        return Response(serializer.errors, status=400)

from rest_framework.permissions import IsAuthenticated

class Details(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        print("USER:", request.user)
        print("AUTH:", request.auth)

        return Response({
            "username": request.user.name,
            "email": request.user.email
        })
