import json
from django.views.generic import ListView, DetailView, CreateView, UpdateView, View
from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from django.contrib.auth import login, update_session_auth_hash
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import PasswordChangeForm
from django.db.models import Count, Q
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt

# REST Framework imports
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response

from .models import Company, Job, Application, User, Notification
from .serializers import JobSerializer, UserSerializer
from .forms import SeekerSignUpForm, EmployerSignUpForm, JobPostForm



def index(request):
    latest_jobs = Job.objects.annotate(total_applicants=Count('applications')).order_by('-created_at')[:4]
    return render(request, 'jobs/index.html', {'latest_jobs': latest_jobs})

@login_required
def profile_settings(request):
    user = request.user
    pass_form = PasswordChangeForm(user)
    if request.method == 'POST':
        if 'update_profile' in request.POST:
            new_username = request.POST.get('username')
            new_email = request.POST.get('email')
            if User.objects.filter(username=new_username).exclude(pk=user.pk).exists():
                messages.error(request, "Username already exists.")
            else:
                user.username = new_username
                user.email = new_email
                user.save()
                messages.success(request, "Profile updated successfully.")
                return redirect('profile-settings')
        elif 'update_password' in request.POST:
            pass_form = PasswordChangeForm(user, request.POST)
            if pass_form.is_valid():
                user = pass_form.save()
                update_session_auth_hash(request, user) 
                messages.success(request, "Password updated successfully.")
                return redirect('profile-settings')
            else:
                messages.error(request, "Please correct the error below.")
    return render(request, 'jobs/profile.html', {'pass_form': pass_form})

@login_required
def notifications_view(request):
    notifications = request.user.notifications.all().order_by('-created_at')
    request.user.notifications.filter(is_read=False).update(is_read=True)
    return render(request, 'jobs/notifications.html', {'notifications': notifications})

def signup_choice(request):
    return render(request, 'jobs/signup_choice.html')

def seeker_signup(request):
    if request.method == 'POST':
        form = SeekerSignUpForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            return redirect('/')
    else:
        form = SeekerSignUpForm() 
    return render(request, 'jobs/signup.html', {'form': form, 'role': 'Job Seeker','button_text': 'Get Started'}) 

def employer_signup(request):
    if request.method == 'POST':
        form = EmployerSignUpForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            return redirect('employer-dashboard')
    else:
        form = EmployerSignUpForm()
    return render(request, 'jobs/signup.html', {'form':form, 'role': 'Employer'})


def update_application_status(request, pk):
    application = get_object_or_404(Application, pk=pk)
    if application.job.company.user != request.user:
        return redirect('home')
    if request.method == 'POST':
        new_status = request.POST.get('status')
        if new_status in ['Shortlisted', 'Accepted', 'Rejected']:
            application.status = new_status
            application.save()
            Notification.objects.create(
                recipient=application.applicant,
                message=f"Your application for '{application.job.title}' has been updated to: {new_status}."
            ) 
            messages.success(request, f"Status updated for {application.applicant.username}.") 
    return redirect('employer-dashboard')

class JobListView(ListView):
    model = Job
    template_name = 'jobs/job_list.html'
    context_object_name = 'jobs'
    def get_queryset(self):
        queryset = Job.objects.annotate(total_applicants=Count('applications'))
        q = self.request.GET.get('q', '').strip()
        location = self.request.GET.get('location', '').strip()
        work_type = self.request.GET.get('work_type', '').strip()
        location_type = self.request.GET.get('location_type', '').strip()
        sort = self.request.GET.get('sort', 'date')
        if q: queryset = queryset.filter(Q(title__icontains=q) | Q(company__name__icontains=q))
        if location: queryset = queryset.filter(location__icontains=location)      
        if work_type: queryset = queryset.filter(work_type=work_type)
        if location_type: queryset = queryset.filter(location_type=location_type)
        return queryset.order_by('-salary_range' if sort == 'salary' else '-created_at')
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['work_types_list'] = ['Full-time', 'Part-time', 'Contract', 'Internship']
        context['location_types_list'] = ['On-site', 'Remote', 'Hybrid']
        context['sel_work_type'] = self.request.GET.get('work_type','')
        context['sel_loc_type'] = self.request.GET.get('location_type','')
        return context

class JobDetailView(DetailView):
    model = Job
    template_name = 'jobs/job_detail.html'
    context_object_name = 'job'  
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if self.request.user.is_authenticated:
            context['has_applied'] = Application.objects.filter(job=self.get_object(), applicant=self.request.user).exists()
        return context

@method_decorator(csrf_exempt, name='dispatch')
class JobCreateView(LoginRequiredMixin, CreateView):
    model = Job
    form_class = JobPostForm
    template_name = 'jobs/job_form.html'
    success_url = '/employer/dashboard/'
    def post(self, request, *args, **kwargs):
        if request.content_type == 'application/json':
            data = json.loads(request.body)
            job = Job.objects.create(
                company=request.user.employer_profile,
                title=data.get('title'),
                description=data.get('description'),
                location=data.get('location'),
                salary_range=data.get('salary_range'),
                work_type=data.get('work_type', 'Full-time'),
                location_type=data.get('location_type', 'Remote'),
                category=data.get('category', 'Tech')
            )
            return JsonResponse({"status": "success"}, status=201)
        return super().post(request, *args, **kwargs)
    def form_valid(self, form):
        form.instance.company = self.request.user.employer_profile
        return super().form_valid(form)

@method_decorator(csrf_exempt, name='dispatch')
class ApplyJobView(LoginRequiredMixin, View):
    def get(self, request, pk):
        job = get_object_or_404(Job, id=pk)
        if Application.objects.filter(job=job, applicant=request.user).exists():
            messages.warning(request, "You have already applied for this position.")
            return redirect('job-detail', pk=job.id)
        
        from .forms import ApplicationForm
        form = ApplicationForm()
        return render(request, 'jobs/apply_form.html', {'form': form, 'job': job})

    def post(self, request, pk):
        job = get_object_or_404(Job, id=pk)
        
        
        if Application.objects.filter(job=job, applicant=request.user).exists():
            if 'application/json' in request.META.get('HTTP_ACCEPT', ''):
                return JsonResponse({"error": "Already applied"}, status=400)
            return redirect('job-detail', pk=job.id)

       
        cover = request.POST.get('cover_letter', 'Applied via Mobile')
        resume = request.FILES.get('resume')

       
        app = Application.objects.create(
            job=job,
            applicant=request.user,
            cover_letter=cover,
            resume=resume
        )

      
        Notification.objects.create(
            recipient=job.company.user,
            message=f"New Applicant: {request.user.username} for {job.title}"
        )

       
        if 'application/json' in request.META.get('HTTP_ACCEPT', '') or request.content_type == 'application/json':
            return JsonResponse({"status": "success", "id": app.id}, status=201)
        
        
        messages.success(request, "Application submitted successfully! ⚡")
        return redirect('job-detail', pk=job.id)
    
class EmployerDashboardView(LoginRequiredMixin, ListView):
    model = Job
    template_name = 'jobs/employer_dashboard.html'
    context_object_name = 'jobs'
    def get_queryset(self):
        return Job.objects.filter(company__user=self.request.user)

class JobUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Job
    form_class = JobPostForm 
    template_name = 'jobs/job_form.html'
    success_url = '/employer/dashboard/'
    def test_func(self):
        return self.get_object().company.user == self.request.user


class MyJobsView(LoginRequiredMixin, ListView):
    model = Application
    template_name = 'jobs/my_jobs.html'
    context_object_name = 'applications'

    def get_queryset(self):
        return Application.objects.filter(applicant=self.request.user)

@api_view(['POST'])
@permission_classes([AllowAny])
def api_signup(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')
    is_employer = request.data.get('is_employer', False)
    if User.objects.filter(username=username).exists():
        return Response({"error": "Username taken"}, status=400)
    user = User.objects.create_user(username=username, email=email, password=password)
    if is_employer:
        user.is_employer = True
        Company.objects.get_or_create(user=user, name=f"{username}'s Company")
    else:
        user.is_seeker = True
    user.save()
    return Response({"message": "Success"}, status=201)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_user_profile(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_my_applications(request):
    applications = Application.objects.filter(applicant=request.user).order_by('-applied_at')
    data = [{"job_title": app.job.title if app.job else "N/A", "company_name": app.job.company.name if app.job else "N/A", "status": app.status, "applied_at": app.applied_at.strftime("%b %d") if app.applied_at else "N/A"} for app in applications]
    return Response(data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_employer_dashboard(request):
    jobs = Job.objects.filter(company__user=request.user).annotate(app_count=Count('applications'))
    data = [{"id": j.id, "title": j.title, "app_count": j.app_count, "applicants": [{"id": a.id, "name": a.applicant.username, "status": a.status} for a in j.applications.all()]} for j in jobs]
    return Response(data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def api_update_application_status(request, pk): 
    application = get_object_or_404(Application, pk=pk)
    if application.job.company.user != request.user:
        return Response({"error": "Unauthorized"}, status=403)
    new_status = request.data.get('status')
    if new_status in ['Shortlisted', 'Accepted', 'Rejected', 'Pending']:
        application.status = new_status
        application.save()
        Notification.objects.create(recipient=application.applicant, message=f"Status Update: '{application.job.title}' is now {new_status}.")
        return Response({"success": True, "new_status": new_status})
    return Response({"error": "Invalid status"}, status=400)

@api_view(['GET'])
def api_job_list(request):
    jobs = Job.objects.all().order_by('-created_at')
    serializer = JobSerializer(jobs, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_get_notifications(request): 
    notifications = request.user.notifications.all().order_by('-created_at')
    data = [{"message": n.message, "is_read": n.is_read, "created_at": n.created_at} for n in notifications]
    return Response(data)