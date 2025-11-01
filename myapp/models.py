from django.db import models
from django.contrib.auth.models import User

# Create your models here.


class Users(models.Model):
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.CharField(max_length=100)
    gender=models.CharField(max_length=100)
    dob=models.DateField()
    place=models.CharField(max_length=100)
    pin=models.CharField(max_length=100)
    post=models.CharField(max_length=100)
    district=models.CharField(max_length=100)
    state=models.CharField(max_length=100)
    photo=models.CharField(max_length=300)
    USER=models.OneToOneField(User,on_delete=models.CASCADE)

class Points(models.Model):
    points=models.CharField(max_length=300,default=0)
    USER = models.ForeignKey(Users, on_delete=models.CASCADE)

class Product(models.Model):
    name=models.CharField(max_length=100)
    tokens=models.CharField(max_length=100)
    description=models.CharField(max_length=100)
    image=models.CharField(max_length=300)
    category=models.CharField(max_length=100)

class Complaint(models.Model):
    USER = models.ForeignKey(Users, on_delete=models.CASCADE)
    date = models.DateField()
    status=models.CharField(max_length=100)
    complaint_text=models.CharField(max_length=100)
    reply=models.CharField(max_length=100)


class Proof(models.Model):
    USER = models.ForeignKey(Users, on_delete=models.CASCADE)
    date = models.DateField()
    latitude=models.CharField(max_length=100)
    longitude=models.CharField(max_length=100)
    status=models.CharField(max_length=100)
    proof=models.CharField(max_length=500)
    title=models.CharField(max_length=500)


