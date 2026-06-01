from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Company, Job, Application, User

@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display = ('title', 'company', 'category', 'location', 'created_at')
    list_filter = ('category', 'location')
    search_fields = ('title', 'description')

class CustomUserAdmin(UserAdmin):
   
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('is_seeker', 'is_employer')}),
    )
    list_display = ['username', 'email', 'is_seeker', 'is_employer', 'is_staff']

admin.site.register(User, CustomUserAdmin)
admin.site.register(Company)
admin.site.register(Application)