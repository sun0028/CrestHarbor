from django import forms
from .models import Application, User, Company, Job

class SeekerSignUpForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput)
    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password"])
        user.is_seeker = True
        if commit:
            user.save()
        return user

class EmployerSignUpForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput)
    company_name = forms.CharField(max_length=200)
    website = forms.URLField()
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password"])
        user.is_employer = True
        if commit:
            user.save()
            
            Company.objects.create(
                user=user, 
                name=self.cleaned_data['company_name'], 
                website=self.cleaned_data['website']
            )
        return user

class JobPostForm(forms.ModelForm):
    class Meta:
        model = Job
        fields = ['title', 'description', 'location', 'category','location_type', 'work_type',  'salary_range']


class ApplicationForm(forms.ModelForm):
    class Meta:
        model = Application
        fields = ['cover_letter', 'resume']
        widgets = {
            'cover_letter': forms.Textarea(attrs={'rows': 4, 'placeholder': 'Tell the employer why you are a good fit...'}),
        }