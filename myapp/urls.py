"""
URL configuration for Eco_Frnd project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from myapp import views

urlpatterns = [
    path('admin/', admin.site.urls),

    path('login_get/', views.login_get),
    path('login_post/', views.login_post),
    path('logout_post/', views.logout_post),

    path('admin_home/', views.admin_home),

    path('add_product_get/', views.add_product_get),
    path('add_product_post/', views.add_product_post),

    path('view_product/', views.view_product),

    path('edit_product_get/<id>', views.edit_product_get),
    path('edit_product_post/', views.edit_product_post),

    path('delete_product/<id>', views.delete_product),

    path('view_complaint_get/', views.view_complaint_get),
    path('sentreply_get/<id>', views.sentreply_get),
    path('sentreply_post/', views.sentreply_post),

    path('changepass_get/', views.changepass_get),
    path('changepass_post/', views.changepass_post),

    path('view_user_get/', views.view_user_get),
    path('view_user_points_get/', views.view_user_points_get),

    path('forgot_password/', views.forgot_password),
    path('forgotpassword_post/', views.forgotpassword_post),

    path('view_proof_get/', views.view_proof_get),
    path('approve_proof_get/<id>', views.approve_proof_get),
    path('reject_proof_get/<id>', views.reject_proof_get),

    path('view_approved_proof_get/', views.view_approved_proof_get),
    path('view_rejected_proof_get/', views.view_rejected_proof_get),

    ### Android
    path('user_signup_post/', views.user_signup_post),
    path('user_login_post/', views.user_login_post),
    path('user_view_profile/', views.user_view_profile),
    path('user_edit_profile/', views.user_edit_profile),
    path('user_upload_proof/', views.user_upload_proof),
    path('user_send_complaint/', views.user_send_complaint),
    path('user_view_reply/', views.user_view_reply),
    path('user_view_product/', views.user_view_product),
    path('user_change_password/', views.user_change_password),
    path('android_forget_password_post/', views.android_forget_password_post),
    path('update_tokens/', views.update_tokens),
    path('user_view_tokens/', views.user_view_tokens),
    path('user_upload_image/', views.user_upload_image),
]
