class JobPostModel {
  int? id;
  String? partnerId;
  String? createdBy;
  String? jobTitle;
  String? jobCode;
  String? jobCity;
  String? country;
  String? radiusRule;
  String? distanceKm;
  int? departmentId;
  int? branchId;
  String? employmentType;
  String? experience;
  String? salary;
  int? vacanciesCount;
  String? referralBudget;
  String? referralAmount;
  String? banner;
  String? applicationDeadline;
  String? jobDescription;
  String? skills;
  String? status;
  String? bannerUrl;
  String? resumeUrl;
  String? designation;
  String? address;
  String? referralCode;
  String? createdAt;
  String? updatedAt;
  JobDepartment? department;
  JobBranch? branch;
  JobCreator? creator;

  JobPostModel({
    this.id,
    this.partnerId,
    this.createdBy,
    this.jobTitle,
    this.jobCode,
    this.jobCity,
    this.country,
    this.radiusRule,
    this.distanceKm,
    this.departmentId,
    this.branchId,
    this.employmentType,
    this.experience,
    this.salary,
    this.vacanciesCount,
    this.referralBudget,
    this.referralAmount,
    this.banner,
    this.applicationDeadline,
    this.jobDescription,
    this.skills,
    this.status,
    this.bannerUrl,
    this.resumeUrl,
    this.designation,
    this.address,
    this.referralCode,
    this.createdAt,
    this.updatedAt,
    this.department,
    this.branch,
    this.creator,
  });

  JobPostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    partnerId = json['partner_id']?.toString();
    createdBy = json['created_by']?.toString();
    jobTitle = json['job_title']?.toString();
    jobCode = json['job_code']?.toString();
    jobCity = json['job_city']?.toString();
    country = json['country']?.toString();
    radiusRule = json['radius_rule']?.toString();
    distanceKm = json['distance_km']?.toString();
    departmentId = json['department_id'] != null ? int.tryParse(json['department_id'].toString()) : null;
    branchId = json['branch_id'] != null ? int.tryParse(json['branch_id'].toString()) : null;
    employmentType = json['employment_type']?.toString();
    experience = json['experience']?.toString();
    salary = json['salary']?.toString();
    vacanciesCount = json['vacancies_count'] != null ? int.tryParse(json['vacancies_count'].toString()) : null;
    referralBudget = json['referral_budget']?.toString();
    referralAmount = json['referral_amount']?.toString();
    banner = json['banner']?.toString();
    applicationDeadline = json['application_deadline']?.toString();
    jobDescription = json['job_description']?.toString();
    skills = json['skills']?.toString();
    status = json['status']?.toString();
    bannerUrl = json['banner_url']?.toString();
    resumeUrl = (json['resume_url'] ?? json['resume'] ?? json['file_url'] ?? json['file'] ?? json['cv_url'] ?? json['document_url'])?.toString();
    designation = json['designation']?.toString();
    address = json['address']?.toString();
    referralCode = json['referral_code']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    // Fallback if data is wrapped inside nested 'job_post' or 'job'
    if (json['job_post'] is Map || json['job'] is Map) {
      final Map<String, dynamic> jobData = Map<String, dynamic>.from(json['job_post'] ?? json['job']);
      jobTitle = jobTitle ?? jobData['job_title']?.toString();
      jobCode = jobCode ?? jobData['job_code']?.toString();
      jobCity = jobCity ?? jobData['job_city']?.toString();
      country = country ?? jobData['country']?.toString();
      radiusRule = radiusRule ?? jobData['radius_rule']?.toString();
      distanceKm = distanceKm ?? jobData['distance_km']?.toString();
      employmentType = employmentType ?? jobData['employment_type']?.toString();
      experience = experience ?? jobData['experience']?.toString();
      salary = salary ?? jobData['salary']?.toString();
      vacanciesCount = vacanciesCount ?? (jobData['vacancies_count'] != null ? int.tryParse(jobData['vacancies_count'].toString()) : null);
      referralBudget = referralBudget ?? jobData['referral_budget']?.toString();
      referralAmount = referralAmount ?? jobData['referral_amount']?.toString();
      applicationDeadline = applicationDeadline ?? jobData['application_deadline']?.toString();
      jobDescription = jobDescription ?? jobData['job_description']?.toString();
      skills = skills ?? jobData['skills']?.toString();
      status = status ?? jobData['status']?.toString();
      bannerUrl = bannerUrl ?? jobData['banner_url']?.toString();
      if (department == null && jobData['department'] != null) {
        department = JobDepartment.fromJson(Map<String, dynamic>.from(jobData['department']));
      }
      if (branch == null && jobData['branch'] != null) {
        branch = JobBranch.fromJson(Map<String, dynamic>.from(jobData['branch']));
      }
      if (creator == null && jobData['creator'] != null) {
        creator = JobCreator.fromJson(Map<String, dynamic>.from(jobData['creator']));
      }
    }

    department = department ?? (json['department'] != null ? JobDepartment.fromJson(Map<String, dynamic>.from(json['department'])) : null);
    branch = branch ?? (json['branch'] != null ? JobBranch.fromJson(Map<String, dynamic>.from(json['branch'])) : null);
    creator = creator ?? (json['creator'] != null ? JobCreator.fromJson(Map<String, dynamic>.from(json['creator'])) : null);
  }
}

class JobDepartment {
  int? id;
  String? name;
  String? description;

  JobDepartment({this.id, this.name, this.description});

  JobDepartment.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    description = json['description']?.toString();
  }
}

class JobBranch {
  int? id;
  String? name;
  String? address;

  JobBranch({this.id, this.name, this.address});

  JobBranch.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    address = json['address']?.toString();
  }
}

class JobCreator {
  String? id;
  String? name;
  String? email;
  String? mobile;
  String? workingMode;
  String? profileImageUrl;

  JobCreator({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.workingMode,
    this.profileImageUrl,
  });

  JobCreator.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    email = json['email']?.toString();
    mobile = json['mobile']?.toString();
    workingMode = json['working_mode']?.toString();
    profileImageUrl = json['profile_image_url']?.toString();
  }
}
