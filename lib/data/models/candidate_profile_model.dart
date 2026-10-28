class CandidateProfileResponse {
  bool? success;
  String? message;
  CandidateUserData? user;
  CandidateProfileData? profile;

  CandidateProfileResponse({
    this.success,
    this.message,
    this.user,
    this.profile,
  });

  factory CandidateProfileResponse.fromJson(Map<String, dynamic> json) {
    CandidateUserData? userObj;
    CandidateProfileData? profileObj;

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;

      if (dataMap.containsKey('user') && dataMap['user'] != null) {
        userObj = CandidateUserData.fromJson(dataMap['user'] as Map<String, dynamic>);
      }

      if (dataMap.containsKey('profile') && dataMap['profile'] != null) {
        profileObj = CandidateProfileData.fromJson(dataMap['profile'] as Map<String, dynamic>);
      } else if (dataMap.containsKey('id') || dataMap.containsKey('user_id')) {
        profileObj = CandidateProfileData.fromJson(dataMap);
      }
    }

    return CandidateProfileResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      user: userObj,
      profile: profileObj,
    );
  }
}

class CandidateUserData {
  String? name;
  String? email;
  String? mobile;
  String? profileImageUrl;

  CandidateUserData({
    this.name,
    this.email,
    this.mobile,
    this.profileImageUrl,
  });

  factory CandidateUserData.fromJson(Map<String, dynamic> json) {
    return CandidateUserData(
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'profile_image_url': profileImageUrl,
    };
  }
}

class CandidateEducation {
  String? degree;
  String? university;
  String? medium;
  String? type;

  CandidateEducation({
    this.degree,
    this.university,
    this.medium,
    this.type,
  });

  factory CandidateEducation.fromJson(Map<String, dynamic> json) {
    return CandidateEducation(
      degree: json['degree'] as String?,
      university: json['university'] as String?,
      medium: json['medium'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'university': university,
      'medium': medium,
      'type': type,
    };
  }
}

class CandidateWorkExperience {
  String? jobTitle;
  String? company;
  String? industry;
  bool? currentlyWorking;
  String? type;

  CandidateWorkExperience({
    this.jobTitle,
    this.company,
    this.industry,
    this.currentlyWorking,
    this.type,
  });

  factory CandidateWorkExperience.fromJson(Map<String, dynamic> json) {
    return CandidateWorkExperience(
      jobTitle: json['job_title'] as String?,
      company: json['company'] as String?,
      industry: json['industry'] as String?,
      currentlyWorking: json['currently_working'] is bool
          ? json['currently_working']
          : (json['currently_working'] == 1 ||
              json['currently_working'] == "1" ||
              json['currently_working'] == "true"),
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': jobTitle,
      'company': company,
      'industry': industry,
      'currently_working': currentlyWorking,
      'type': type,
    };
  }
}

class CandidateProfileData {
  dynamic id;
  String? userId;
  String? highestEducation;
  String? doctorate;
  List<CandidateEducation>? educations;
  List<String>? skills;
  String? resumePath;
  String? resumeUpdatedAt;
  List<String>? preferredJobRoles;
  List<String>? preferredLocations;
  String? preferredJobType;
  String? preferredWorkMode;
  String? preferredShift;
  dynamic expectedSalary;
  List<String>? documentsAndAssets;
  List<CandidateWorkExperience>? workExperiences;
  int? totalExperienceYears;
  int? totalExperienceMonths;
  dynamic currentMonthlySalary;
  List<dynamic>? internships;
  String? gender;
  String? createdAt;
  String? updatedAt;

  CandidateProfileData({
    this.id,
    this.userId,
    this.highestEducation,
    this.doctorate,
    this.educations,
    this.skills,
    this.resumePath,
    this.resumeUpdatedAt,
    this.preferredJobRoles,
    this.preferredLocations,
    this.preferredJobType,
    this.preferredWorkMode,
    this.preferredShift,
    this.expectedSalary,
    this.documentsAndAssets,
    this.workExperiences,
    this.totalExperienceYears,
    this.totalExperienceMonths,
    this.currentMonthlySalary,
    this.internships,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  factory CandidateProfileData.fromJson(Map<String, dynamic> json) {
    List<CandidateEducation>? eduList;
    if (json['educations'] != null && json['educations'] is List) {
      eduList = (json['educations'] as List)
          .map((e) => CandidateEducation.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String>? skillsList;
    if (json['skills'] != null && json['skills'] is List) {
      skillsList = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    List<String>? preferredRoles;
    if (json['preferred_job_roles'] != null && json['preferred_job_roles'] is List) {
      preferredRoles = (json['preferred_job_roles'] as List).map((e) => e.toString()).toList();
    }

    List<String>? preferredLocs;
    if (json['preferred_locations'] != null && json['preferred_locations'] is List) {
      preferredLocs = (json['preferred_locations'] as List).map((e) => e.toString()).toList();
    }

    List<String>? docs;
    if (json['documents_and_assets'] != null && json['documents_and_assets'] is List) {
      docs = (json['documents_and_assets'] as List).map((e) => e.toString()).toList();
    }

    List<CandidateWorkExperience>? workExps;
    if (json['work_experiences'] != null && json['work_experiences'] is List) {
      workExps = (json['work_experiences'] as List)
          .map((e) => CandidateWorkExperience.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CandidateProfileData(
      id: json['id'],
      userId: json['user_id'] as String?,
      highestEducation: json['highest_education'] as String?,
      doctorate: json['doctorate'] as String?,
      educations: eduList,
      skills: skillsList,
      resumePath: json['resume_path'] as String?,
      resumeUpdatedAt: json['resume_updated_at'] as String?,
      preferredJobRoles: preferredRoles,
      preferredLocations: preferredLocs,
      preferredJobType: json['preferred_job_type'] as String?,
      preferredWorkMode: json['preferred_work_mode'] as String?,
      preferredShift: json['preferred_shift'] as String?,
      expectedSalary: json['expected_salary'],
      documentsAndAssets: docs,
      workExperiences: workExps,
      totalExperienceYears: json['total_experience_years'] is int
          ? json['total_experience_years']
          : int.tryParse(json['total_experience_years']?.toString() ?? '0'),
      totalExperienceMonths: json['total_experience_months'] is int
          ? json['total_experience_months']
          : int.tryParse(json['total_experience_months']?.toString() ?? '0'),
      currentMonthlySalary: json['current_monthly_salary'],
      internships: json['internships'] is List ? json['internships'] as List : null,
      gender: json['gender'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (highestEducation != null) 'highest_education': highestEducation,
      if (doctorate != null) 'doctorate': doctorate,
      if (educations != null) 'educations': educations!.map((e) => e.toJson()).toList(),
      if (skills != null) 'skills': skills,
      if (preferredJobRoles != null) 'preferred_job_roles': preferredJobRoles,
      if (preferredLocations != null) 'preferred_locations': preferredLocations,
      if (preferredJobType != null) 'preferred_job_type': preferredJobType,
      if (preferredWorkMode != null) 'preferred_work_mode': preferredWorkMode,
      if (preferredShift != null) 'preferred_shift': preferredShift,
      if (expectedSalary != null) 'expected_salary': expectedSalary,
      if (documentsAndAssets != null) 'documents_and_assets': documentsAndAssets,
      if (workExperiences != null) 'work_experiences': workExperiences!.map((e) => e.toJson()).toList(),
      if (totalExperienceYears != null) 'total_experience_years': totalExperienceYears,
      if (totalExperienceMonths != null) 'total_experience_months': totalExperienceMonths,
      if (currentMonthlySalary != null) 'current_monthly_salary': currentMonthlySalary,
      if (internships != null) 'internships': internships ?? [],
      if (gender != null) 'gender': gender,
    };
  }
}
