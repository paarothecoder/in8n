
from django.contrib import admin
from django.urls import path
from user import views
from .views import *

urlpatterns = [
    path('register/', Register.as_view(), name="register"),
    path('login/',Login.as_view(), name='login'),
    path('details/',Details.as_view(), name='details'),
]
