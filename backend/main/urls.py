
from django.contrib import admin
from django.urls import path
from user import views
from .views import *

urlpatterns = [
    path('set/' ,Setflow.as_view() , name='setflow')
]
