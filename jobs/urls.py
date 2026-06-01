from django.urls import path
from . import views

urlpatterns = [
    # Web Client Routes
    path('', views.index, name='home'),
    path('find-jobs/', views.JobListView.as_view(), name='job-list'),
    path('job/<int:pk>/', views.JobDetailView.as_view(), name='job-detail'),
    path('job/<int:pk>/apply/', views.ApplyJobView.as_view(), name='apply-job'),
    path('my-jobs/', views.MyJobsView.as_view(), name='my-jobs'), 
    path('employer/dashboard/', views.EmployerDashboardView.as_view(), name='employer-dashboard'),
    path('employer/post-job/', views.JobCreateView.as_view(), name='post-job'),
    path('job/<int:pk>/edit/', views.JobUpdateView.as_view(), name='edit-job'),
    path('application/<int:pk>/status/', views.update_application_status, name='update-status'),
    
    # Auth & Profile
    path('signup/', views.signup_choice, name='signup-choice'),
    path('signup/seeker/', views.seeker_signup, name='seeker-signup'),
    path('signup/employer/', views.employer_signup, name='employer-signup'),
    path('profile/', views.profile_settings, name='profile-settings'),
    path('notifications/', views.notifications_view, name='notifications'),
    
    # Mobile API Endpoints 
    path('api/signup/', views.api_signup, name='api-signup'),
    path('api/profile/', views.api_user_profile, name='api-profile'),
    path('api/jobs/', views.api_job_list, name='api-jobs'),
    path('api/my-applications/', views.api_my_applications, name='api-my-apps'),
    path('api/employer-dashboard/', views.api_employer_dashboard, name='api-employer-dash'),
    path('api/notifications/', views.api_get_notifications, name='api-notifications'), 
    path('api/application/<int:pk>/status/', views.api_update_application_status, name='api-update-status'), 
]