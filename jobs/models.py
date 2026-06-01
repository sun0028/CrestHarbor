from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings

class User(AbstractUser):
    is_seeker = models.BooleanField(default=False)
    is_employer = models.BooleanField(default=False)

CATEGORY_CHOICES = [
    ('Tech', 'Technology'),
    ('Healthcare', 'Healthcare'),
    ('Finance', 'Finance'),
    ('Education', 'Education'),
    ('Marketing', 'Marketing'),
    ('Sales', 'Sales'),
]

WORK_TYPE_CHOICES = [
    ('Full-time', 'Full-time'),
    ('Part-time', 'Part-time'),
    ('Contract', 'Contract'),
    ('Internship', 'Internship'),
]

LOCATION_TYPE_CHOICES = [
    ('On-site', 'On-site'),
    ('Remote', 'Remote'),
    ('Hybrid', 'Hybrid'),
]

class Company(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='employer_profile')
    name = models.CharField(max_length=200)
    description = models.TextField()
    website = models.URLField()
    def __str__(self): return self.name

class Job(models.Model):
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='jobs')
    title = models.CharField(max_length=255)
    description = models.TextField()
    location = models.CharField(max_length=100)
    
    
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='Tech')
    location_type = models.CharField(max_length=20, choices=LOCATION_TYPE_CHOICES, default='On-site')
    work_type = models.CharField(max_length=20, choices=WORK_TYPE_CHOICES, default='Full-time')
    
    salary_range = models.CharField(max_length=100, help_text="e.g. $100k - $120k")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self): return f"{self.title} at {self.company.name}"

class Application(models.Model):
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='applications')
    applicant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    resume = models.FileField(upload_to='resumes/')
    cover_letter = models.TextField()
    status = models.CharField(max_length=20, default='Pending')
    applied_at = models.DateTimeField(auto_now_add=True)

class Notification(models.Model):
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Notification for {self.recipient.username}"