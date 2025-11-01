import random
import smtplib
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User, Group
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt

from myapp.models import *

# Create your views here.

def admin_home(request):
    # return render(request, "admin_home.html")
    return render(request, "adminindex.html")

def login_get(request):
    return render(request, "login.html")
def login_post(request):
    username = request.POST['username']
    password = request.POST['password']
    user=authenticate(request,username=username,password=password)
    if user is not None:
        login(request,user)
        if user.groups.filter(name="Admin"):
            return redirect("/myapp/admin_home/")
        else:
            return redirect("/myapp/login_get/")
    else:
        return redirect("/myapp/login_get/")


def logout_post(request):
    logout(request)
    return redirect('/myapp/login_get/')

def add_product_get(request):
    return render(request,'add_product.html')
def add_product_post(request):
    name = request.POST['name']
    tokens = request.POST['tokens']
    description = request.POST['description']
    image = request.FILES['image']
    category = request.POST['category']


    fs=FileSystemStorage()
    date=datetime.now().strftime("%Y%m%d%H%M%S")+".jpg"
    fs.save(date,image)
    path=fs.url(date)

    a = Product()
    a.name = name
    a.tokens = tokens
    a.description = description
    a.image = path
    a.category = category
    a.save()
    return redirect('/myapp/view_product/')


def view_product(request):
    d=Product.objects.all()
    return render(request,'view_product.html',{'data':d})


def edit_product_get(request,id):
    d=Product.objects.get(id=id)
    return render(request, 'edit_product.html',{'data':d})
def edit_product_post(request):
    name = request.POST['name']
    tokens = request.POST['tokens']
    description = request.POST['description']
    category = request.POST['category']
    id = request.POST['id']

    a = Product.objects.get(id=id)

    if 'image' in request.FILES:
        image = request.FILES['image']
        fs = FileSystemStorage()
        date = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
        fs.save(date, image)
        path = fs.url(date)
        a.image = path
        a.save()

    a.name = name
    a.tokens = tokens
    a.description = description
    a.category = category
    a.save()
    return redirect('/myapp/view_product/')

def delete_product(request,id):
    Product.objects.get(id=id).delete()
    return redirect('/myapp/view_product/')


def view_complaint_get(request):
    data = Complaint.objects.all()
    return render(request, "view_complaint.html",{'data':data})

def sentreply_get(request,id):
    return render(request, "sentreply.html",{'id':id})
def sentreply_post(request):
    reply = request.POST['reply']
    id = request.POST['id']
    data=Complaint.objects.get(id=id)
    data.reply_text=reply
    data.save()
    return redirect('/myapp/admin_view_complaint_get/')

def changepass_get(request):
    return render(request, "changepassword.html")
def changepass_post(request):
    currentpassword = request.POST['currentPassword']
    newpassword = request.POST['newPassword']
    confirmpassword = request.POST['confirmPassword']
    user=request.user
    if user.check_password(currentpassword):
        if newpassword==confirmpassword:
            user.set_password(newpassword)
            user.save()
            return redirect('/myapp/login_get/')
        else:
            return redirect('/myapp/changepass_get/')
    else:
        return redirect('/myapp/changepass_get/')




def view_user_get(request):
    data = Users.objects.all()
    return render(request, "view_users.html",{'data':data})


def view_user_points_get(request):
    data = Points.objects.all()
    return render(request, "view_users_points.html",{'data':data})


def view_proof_get(request):
    data = Proof.objects.all()
    return render(request, "view_proof.html",{'data':data})

def approve_proof_get(request, id):
    # Update status
    Proof.objects.filter(id=id).update(status='verified')

    # Get the proof object
    proof = Proof.objects.get(id=id)
    title = proof.title
    uid   = proof.USER.id

    # Assign tokens based on title
    if title == 'Energy Saving':
        tokens = 150
    elif title == 'Waste Management':
        tokens = 120
    elif title == 'Carpooling':
        tokens = 200
    elif title == 'Tree Planting':
        tokens = 300
    elif title == 'Eco Shopping':
        tokens = 100
    else:
        tokens = 0

    # Update user points
    pts = Points.objects.get(USER=Users.objects.get(id=uid))
    current_points = int(pts.points)
    new_total = current_points + tokens
    pts.points = str(new_total)
    pts.save()

    return redirect('/myapp/view_proof_get/')

def reject_proof_get(request,id):
    Proof.objects.filter(id=id).update(status='rejected')
    redirect('/myapp/view_proof_get/')

def view_approved_proof_get(request):
    data = Proof.objects.filter(status='verified')
    return render(request, "view_approved_proof.html",{'data':data})

def view_rejected_proof_get(request):
    data = Proof.objects.filter(status='rejected')
    return render(request, "view_rejected_proof.html",{'data':data})


def forgot_password(request):
    return render(request,'forgotten_password.html')

def forgotpassword_post(request):

    email=request.POST['email']

    if User.objects.filter(username=email).exists():

        import random
        new_pass = random.randint(00000, 99999)
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login("trainingstarted@gmail.com", " nlxasujxgazlbmgz")  # App Password
        to = email
        subject = "Test Email"
        body = "Your new password is " + str(new_pass)
        msg = f"Subject: {subject}\n\n{body}"
        server.sendmail("s@gmail.com", to, msg)  # Disconnect from the server
        server.quit()

        user = User.objects.get(username=email)
        user.set_password(new_pass)
        user.save()

        return redirect('/myapp/login_get/')
    else:
        messages.warning(request, 'email not  exists')
        return redirect('/myapp/forgot_password/')

########### USER Android

@csrf_exempt
def user_signup_post(request):
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    gender=request.POST['gender']
    dob=request.POST['dob']
    place=request.POST['place']
    pin=request.POST['pin']
    post=request.POST['post']
    district=request.POST['district']
    state=request.POST['state']
    photo=request.FILES['photo']
    password=request.POST['password']
    confirmpass=request.POST['confirmpass']

    fs=FileSystemStorage()
    date=datetime.now().strftime("%Y%m%d%H%M%S")+".jpg"
    fs.save(date,photo)
    path=fs.url(date)

    if User.objects.filter(username=email).exists():
        messages.error(request, 'Email already exists!')
        return redirect('/myapp/user_registration_get/')
    elif password == confirmpass:
        user = User.objects.create_user(username=email, password=confirmpass)
        user.groups.add(Group.objects.get(name='Users'))
        user.save()

        a=Users()
        a.name=name
        a.email=email
        a.phone=phone
        a.gender=gender
        a.dob=dob
        a.place=place
        a.pin=pin
        a.post=post
        a.district=district
        a.photo=path
        a.state=state
        a.USER=user
        a.save()


        b=Points()
        b.points='0'
        b.USER=Users.objects.get(id=a.id)
        b.save()

        return  JsonResponse({'status':'ok'})
    else:
        return JsonResponse({'status':'invalid'})

@csrf_exempt
def user_login_post(request):
    user_name=request.POST['username']
    pass_word=request.POST['password']

    user = authenticate(request,username=user_name,password=pass_word)

    if user is not None:
        login(request, user)
        if user.groups.filter(name='Users').exists():
            p=Points.objects.get(USER__USER_id=user.id)
            print(p)
            return JsonResponse({'status': 'ok','type':'User','lid':str(user.id),'point':str(p.points)})

        else:
            return JsonResponse({'status': 'invalid'})
    else:
        return JsonResponse({'status': 'invalid'})

@csrf_exempt
def user_view_profile(request):
    lid=request.POST['lid']

    a=Users.objects.get(USER_id=lid)

    return JsonResponse({'status':'ok',
                         'name' : a.name,
                         'email': a.email,
                         'phone': a.phone ,
                         'gender': a.gender,
                         'dob': a.dob ,
                         'place': a.place,
                         'pin':a.pin,
                         'post': a.post,
                         'district': a.district,
                         'state': a.state ,
                         'photo': a.photo ,
                         })

@csrf_exempt
def user_edit_profile(request):
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    gender = request.POST['gender']
    dob = request.POST['dob']
    place = request.POST['place']
    pin = request.POST['pin']
    post = request.POST['post']
    district = request.POST['district']
    state = request.POST['state']

    lid=request.POST['lid']

    a = Users.objects.get(USER_id=lid)

    if 'photo' in request.FILES:
        photo = request.FILES['photo']
        fs = FileSystemStorage()
        date = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
        fs.save(date, photo)
        path = fs.url(date)
        a.photo = path
        a.save()

    a.name = name
    a.email = email
    a.phone = phone
    a.gender = gender
    a.dob = dob
    a.place = place
    a.pin = pin
    a.post = post
    a.district = district
    a.state = state
    a.save()

    return JsonResponse({'status': 'ok'})


@csrf_exempt
# def user_upload_proof(request):
#     photo = request.FILES['photo']
#     latitude = request.POST['latitude']
#     longitude = request.POST['longitude']
#     lid = request.POST['lid']
#
#
#     a = Proof()
#
#     fs = FileSystemStorage()
#     date = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
#     fs.save(date, photo)
#     path = fs.url(date)
#
#
#     a.latitude = latitude
#     a.longitude = longitude
#     a.proof = path
#     a.status='pending'
#     a.date=datetime.now().today()
#     a.USER = Users.objects.get(USER_id=lid)
#     a.save()
#
#     return JsonResponse({'status': 'ok'})
def user_upload_proof(request):
    print("aaaaaaaaaaaaaaa")
    photo = request.FILES['photo']
    print("bbbbbbbbbb")
    latitude = request.POST['latitude']
    print("cccccccccccccccc")
    longitude = request.POST['longitude']
    print("dddddddddddd")
    lid = request.POST['lid']
    print("eeeeeeeeeeeeee")
    title = request.POST['title']
    print("fffffffffffff")


    user = Users.objects.get(USER_id=lid)

    # Save proof
    a = Proof()
    fs = FileSystemStorage()
    date = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
    fs.save(date, photo)
    path = fs.url(date)

    a.latitude = latitude
    a.longitude = longitude
    a.proof = path
    a.status = 'pending'
    a.title = title
    a.date = datetime.now().today()
    a.USER = user
    a.save()


    return JsonResponse({
        'status': 'ok',
        'message': 'Proof uploaded successfully'
        # 'added_points': added_points,
        # 'total_points': new_total
    })

@csrf_exempt
def user_view_reply(request):
    lid=request.POST['lid']
    data=Complaint.objects.filter(USER__USER_id=lid)
    l=[]
    for i in data:
        l.append(
            {
                'id':i.id,
                'date':i.date,
                'status':i.status,
                'complaint':i.complaint_text,
                'reply':i.reply
            }
        )
    return JsonResponse({'status': 'ok','data':l})


@csrf_exempt
def user_send_complaint(request):
    complaint = request.POST['complaint']
    lid = request.POST['lid']


    a = Complaint()
    a.complaint_text = complaint
    a.status = 'pending'
    a.reply = 'pending'
    a.date=datetime.now().today()
    a.USER = Users.objects.get(USER_id=lid)
    a.save()

    return JsonResponse({'status': 'ok'})


@csrf_exempt
def user_view_product(request):
    data=Product.objects.all()
    l=[]
    for i in data:
        l.append(
            {
                'id':i.id,
                'name':i.name,
                'tokens':i.tokens,
                'description':i.description,
                'image':i.image,
                'category':i.category
            }
        )
    print(l)
    return JsonResponse({'status': 'ok','data':l})

@csrf_exempt
def user_change_password(request):
    currentpassword = request.POST['currentpassword']
    newpassword = request.POST['newpassword']
    confirmpassword = request.POST['confirmpassword']
    lid=request.POST['lid']
    user=User.objects.get(id=lid)
    if user.check_password(currentpassword):
        if newpassword == confirmpassword:
            user.set_password(newpassword)
            user.save()
            return JsonResponse({'status': 'ok'})
        else:
            return JsonResponse({'status': 'no'})
    else:
        return JsonResponse({'status': 'no'})


@csrf_exempt
def android_forget_password_post(request):
    email = request.POST.get('email')
    if not email:
        return JsonResponse({'status': 'error', 'message': 'Email is required'})

    try:
        user = User.objects.get(username=email)
        print(email)

        # Generate new password
        new_pass = str(random.randint(1000, 9999))
        user.password = make_password(new_pass)
        user.save()

        # Email configuration
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = "trainingstarted@gmail.com"
        app_password = "nlxasujxgazlbmgz"

        subject = "Your New Password"
        body = f"Your new password is: {new_pass}"
        message = MIMEMultipart()
        message["From"] = sender_email
        message["To"] = email
        message["Subject"] = subject
        message.attach(MIMEText(body, "plain"))

        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(message)
        server.quit()

        return JsonResponse({'status': 'ok', 'message': 'Password sent to your email'})

    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Email not found'})

    except Exception as e:
        return JsonResponse({'status': 'error', 'message': f'Email send error: {str(e)}'})


@csrf_exempt
def update_tokens(request):
    if request.method == 'POST':
        lid = request.POST['lid']
        token = request.POST['token']
        latitude = request.POST.get('latitude', '')
        longitude = request.POST.get('longitude', '')
        title = request.POST.get('title', '')
        photo = request.FILES.get('photo')

        user = Users.objects.get(USER_id=lid)

        proof = Proof(
            USER=user,
            latitude=latitude,
            longitude=longitude,
            title=title,
            status='Redeem',
            date=datetime.now().date(),
            proof=''
        )

        if photo:
            fs = FileSystemStorage()
            filename = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
            fs.save(filename, photo)
            proof.proof = fs.url(filename)

        proof.save()

        points_obj, _ = Points.objects.get_or_create(USER=user)
        current_points = int(points_obj.points)
        added_points = int(token)
        points_obj.points = str(current_points + added_points)
        points_obj.save()

        return JsonResponse({
            'status': 'ok',
            'message': 'Proof and points saved successfully',
            'added_points': added_points,
            'total_points': points_obj.points
        })
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'})

@csrf_exempt
def user_view_tokens(request):
    lid=request.POST['lid']

    p = Points.objects.get(USER__USER_id=lid)

    return JsonResponse({'status':'ok',
                         'points':p.points
                         })


from PIL import Image
import google.generativeai as genai
import re

@csrf_exempt
def user_upload_image(request):
    photo = request.FILES['photo']
    latitude = request.POST['latitude']
    longitude = request.POST['longitude']
    lid = request.POST['lid']
    title = request.POST['title']

    user = Users.objects.get(USER_id=lid)

    # ✅ Save image
    fs = FileSystemStorage()
    filename = datetime.now().strftime("%Y%m%d%H%M%S") + ".jpg"
    filename = fs.save(filename, photo)
    file_path = fs.path(filename)  # Correct local path for PIL

    # ✅ Configure Gemini
    genai.configure(api_key="AIzaSyDM8jCJogG4vlFfTThmM7UaT98m0gMI3ik")
    model = genai.GenerativeModel('gemini-2.5-pro')
    img = Image.open(file_path)

    # ✅ Prompt
    prompt = """
    Identify the eco-friendly activity or content in this image 
    (tree planting, waste management, energy saving, carpooling, eco shopping, electricity bill, etc.).
    If it is an electricity bill, extract or estimate the total bill amount.
    """

    response = model.generate_content([prompt, img])
    text = response.text.strip() if response.text else ""
    print("🔹 Raw Gemini Response:\n", text)

    # ✅ Extract activity
    activity_match = re.search(
        r'(tree planting|waste management|energy saving|carpooling|eco shopping|electricity bill)',
        text,
        re.IGNORECASE,
    )
    activity = activity_match.group(1).title() if activity_match else "Unknown"

    # ✅ Extract bill amount
    amount_match = re.search(r'(?:total|amount|bill)\s*[:\-]?\s*₹?\s*(\d{2,5})', text, re.IGNORECASE)
    amount = int(amount_match.group(1)) if amount_match else 0

    # ✅ Calculate points
    if activity == "Electricity Bill":
        if amount > 0:
            if amount <= 500:
                points = 100
            elif amount <= 1000:
                points = 50
            elif amount <= 5000:
                points = 20
            else:
                points = 0
        else:
            points = 150
    elif activity == "Tree Planting":
        points = 300
    elif activity == "Waste Management":
        points = 200
    elif activity == "Energy Saving":
        points = 150
    elif activity == "Carpooling":
        points = 250
    elif activity == "Eco Shopping":
        points = 180
    else:
        points = 100

    print("\n✅ Extracted Results:")
    print(f"Activity: {activity}")
    if activity == "Electricity Bill":
        print(f"Bill Amount: ₹{amount}")
    print(f"Points: {points}")

    # ✅ Save proof in DB
    proof = Proof()
    proof.proof = fs.url(filename)
    proof.latitude = latitude
    proof.longitude = longitude
    proof.USER = Users.objects.get(USER_id=lid)
    proof.title = title
    proof.date = datetime.now().today()
    proof.status = 'Activity'
    proof.save()

    points_obj, _ = Points.objects.get_or_create(USER=user)
    current_points = int(points_obj.points)
    added_points = int(points)
    points_obj.points = str(current_points + added_points)
    points_obj.save()


    # ✅ Return JSON response
    return JsonResponse({
        'status': 'ok',
        'message': 'Proof uploaded successfully',
        'activity': activity,
        'amount': amount,
        'points': points,
    })

