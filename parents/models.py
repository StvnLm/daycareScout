from django.db import models
from django.conf import settings
# Create your models here.

# Child DB Model
class ChildProfile(models.model):
  # AGE_GROUP_INFANT = "infant"
  # AGE_GROUP_TODDLER = "toddler"
  # AGE_GROUP_PRESCHOOL = "preschool"
  # AGE_GROUP_KINDERGARTEN = "kindergarten"

  AGE_GROUP_CHOICES = [
                        "infant",
                        "toddler",
                        "preschool",
                        "kindergarten",
                      ]


  parents = models.ForeignKey(
    settings.AUTH_USER_MODEL, # Referenced model
    on_delete = models.CASCADE, # Delete child profile if parents deleted
    related_name = "child_profiles" # Allows reverse lookup from parent to child profiles
  )

  first_name = models.CharField(max_length=100)
  last_name = models.CharField(max_length=100, blank=True)
  date_of_birth = models.DateField()
  desired_start_date = models.DateField(blank=True, null=True)
  age_group = models.CharField(max_length=30, choices=AGE_GROUP_CHOICES)
  notes = models.TextField(blank=True)
  allergies = models.TextField(blank=True)
  created_at = models.DateTimeField(auto_now_add=True)
  updated_at = models.DateTimeField(auto_now=True)

