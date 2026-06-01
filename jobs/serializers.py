from rest_framework import serializers
from .models import Job, User, Application

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'is_seeker', 'is_employer']

class JobSerializer(serializers.ModelSerializer):
    company_name = serializers.ReadOnlyField(source='company.name')

    class Meta:
        model = Job
        fields = ['id', 'title', 'company_name', 'location', 'work_type', 'location_type', 'salary_range', 'description', 'created_at']