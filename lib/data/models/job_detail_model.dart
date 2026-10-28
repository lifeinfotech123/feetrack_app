class JobDetailResponse {
  bool? success;
  JobDetailData? data;

  JobDetailResponse({this.success, this.data});

  JobDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? JobDetailData.fromJson(json['data']) : null;
  }
}

class JobDetailData {
  Header? header;
  JobDetailInfo? jobDetail;
  CompanyDetail? companyDetail;
  int? id;
  String? jobCode;
  String? shareLink;
  dynamic referralAmount;
  String? bannerUrl;
  dynamic department;
  Branch? branch;

  JobDetailData({
    this.header,
    this.jobDetail,
    this.companyDetail,
    this.id,
    this.jobCode,
    this.shareLink,
    this.referralAmount,
    this.bannerUrl,
    this.department,
    this.branch,
  });

  JobDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    jobCode = json['job_code']?.toString();
    shareLink = json['share_link']?.toString();
    referralAmount = json['referral_amount'];
    bannerUrl = json['banner_url']?.toString();
    department = json['department'];

    header = json['header'] != null && json['header'] is Map ? Header.fromJson(json['header']) : null;
    jobDetail = json['job_detail'] != null && json['job_detail'] is Map ? JobDetailInfo.fromJson(json['job_detail']) : null;
    companyDetail = json['company_detail'] != null && json['company_detail'] is Map ? CompanyDetail.fromJson(json['company_detail']) : null;
    branch = json['branch'] != null && json['branch'] is Map ? Branch.fromJson(json['branch']) : null;

    // Fallback for flat JSON response (e.g., /hrms/shared-referrals/{referral_code})
    if (header == null && json['job_title'] != null) {
      String? company = json['department'] is Map 
          ? json['department']['name']?.toString() 
          : (json['branch'] is Map ? json['branch']['name']?.toString() : null);
      header = Header(
        jobTitle: json['job_title']?.toString(),
        employmentType: json['employment_type']?.toString(),
        companyName: company,
        logoUrl: json['banner_url']?.toString(),
      );
    }

    if (jobDetail == null && (json['job_description'] != null || json['skills'] != null)) {
      List<String>? parsedSkills;
      if (json['skills'] != null) {
        if (json['skills'] is List) {
          parsedSkills = List<String>.from(json['skills'].map((e) => e.toString()));
        } else if (json['skills'] is String) {
          parsedSkills = [json['skills'].toString()];
        }
      }
      jobDetail = JobDetailInfo(
        descriptions: json['job_description']?.toString(),
        skills: parsedSkills,
        overview: Overview(
          salary: json['salary']?.toString(),
          type: json['employment_type']?.toString(),
          level: json['experience']?.toString(),
        ),
      );
    }
  }
}

class Header {
  String? logoUrl;
  String? jobTitle;
  String? companyName;
  String? employmentType;
  int? applicantsCount;
  String? location;

  Header({
    this.logoUrl,
    this.jobTitle,
    this.companyName,
    this.employmentType,
    this.applicantsCount,
    this.location,
  });

  Header.fromJson(Map<String, dynamic> json) {
    logoUrl = json['logo_url']?.toString();
    jobTitle = json['job_title']?.toString();
    companyName = json['company_name']?.toString();
    employmentType = json['employment_type']?.toString();
    applicantsCount = json['applicants_count'] is int ? json['applicants_count'] : int.tryParse(json['applicants_count']?.toString() ?? '');
    location = json['location']?.toString();
  }
}

class JobDetailInfo {
  Overview? overview;
  String? descriptions;
  List<String>? skills;
  List<String>? responsibilities;
  List<ScreeningQuestion>? screeningQuestions;
  List<String>? additionalPerks;

  JobDetailInfo({
    this.overview,
    this.descriptions,
    this.skills,
    this.responsibilities,
    this.screeningQuestions,
    this.additionalPerks,
  });

  JobDetailInfo.fromJson(Map<String, dynamic> json) {
    overview = json['overview'] != null && json['overview'] is Map ? Overview.fromJson(json['overview']) : null;
    descriptions = json['descriptions']?.toString();
    if (json['skills'] != null && json['skills'] is List) {
      skills = List<String>.from(json['skills'].map((e) => e.toString()));
    }
    if (json['responsibilities'] != null && json['responsibilities'] is List) {
      responsibilities = List<String>.from(json['responsibilities'].map((e) => e.toString()));
    }
    if (json['screening_questions'] != null && json['screening_questions'] is List) {
      screeningQuestions = (json['screening_questions'] as List)
          .map((e) => ScreeningQuestion.fromJson(e))
          .toList();
    }
    if (json['additional_perks'] != null && json['additional_perks'] is List) {
      additionalPerks = List<String>.from(json['additional_perks'].map((e) => e.toString()));
    }
  }
}

class Overview {
  String? salary;
  String? type;
  String? workMode;
  String? level;
  String? jobCity;
  String? distance;

  Overview({
    this.salary,
    this.type,
    this.workMode,
    this.level,
    this.jobCity,
    this.distance,
  });

  Overview.fromJson(Map<String, dynamic> json) {
    salary = json['salary']?.toString();
    type = json['type']?.toString();
    workMode = json['work_mode']?.toString();
    level = json['level']?.toString();
    jobCity = json['job_city']?.toString();
    distance = json['distance']?.toString();
  }
}

class ScreeningQuestion {
  String? id;
  String? question;
  String? type;
  int? required;
  String? options;
  String? conditionalParent;
  String? conditionalValue;

  ScreeningQuestion({
    this.id,
    this.question,
    this.type,
    this.required,
    this.options,
    this.conditionalParent,
    this.conditionalValue,
  });

  ScreeningQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    question = json['question']?.toString();
    type = json['type']?.toString();
    required = json['required'] is int ? json['required'] : int.tryParse(json['required']?.toString() ?? '');
    options = json['options']?.toString();
    conditionalParent = json['conditional_parent']?.toString();
    conditionalValue = json['conditional_value']?.toString();
  }
}

class CompanyDetail {
  String? logoUrl;
  String? companyName;
  String? aboutCompany;
  Details? details;
  SocialLinks? socialLinks;

  CompanyDetail({
    this.logoUrl,
    this.companyName,
    this.aboutCompany,
    this.details,
    this.socialLinks,
  });

  CompanyDetail.fromJson(Map<String, dynamic> json) {
    logoUrl = json['logo_url']?.toString();
    companyName = json['company_name']?.toString();
    aboutCompany = json['about_company']?.toString();
    details = json['details'] != null && json['details'] is Map ? Details.fromJson(json['details']) : null;
    socialLinks = json['social_links'] != null && json['social_links'] is Map ? SocialLinks.fromJson(json['social_links']) : null;
  }
}

class Details {
  String? website;
  String? headquarters;
  String? industry;
  String? companySize;
  String? companyType;
  String? foundedYear;

  Details({
    this.website,
    this.headquarters,
    this.industry,
    this.companySize,
    this.companyType,
    this.foundedYear,
  });

  Details.fromJson(Map<String, dynamic> json) {
    website = json['website']?.toString();
    headquarters = json['headquarters']?.toString();
    industry = json['industry']?.toString();
    companySize = json['company_size']?.toString();
    companyType = json['company_type']?.toString();
    foundedYear = json['founded_year']?.toString();
  }
}

class SocialLinks {
  String? linkedin;
  String? facebook;
  String? instagram;

  SocialLinks({this.linkedin, this.facebook, this.instagram});

  SocialLinks.fromJson(Map<String, dynamic> json) {
    linkedin = json['linkedin']?.toString();
    facebook = json['facebook']?.toString();
    instagram = json['instagram']?.toString();
  }
}

class Branch {
  int? id;
  String? partnerId;
  String? name;
  String? address;
  String? lat;
  String? lng;
  num? radius;
  dynamic managerId;
  String? status;
  String? companyLogo;
  String? gstNumber;
  String? createdAt;
  String? updatedAt;
  String? foundedYear;
  String? website;
  String? companySize;
  String? companyType;
  String? industry;
  String? aboutCompany;
  String? linkedinUrl;
  String? facebookUrl;
  String? instagramUrl;

  Branch({
    this.id,
    this.partnerId,
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.radius,
    this.managerId,
    this.status,
    this.companyLogo,
    this.gstNumber,
    this.createdAt,
    this.updatedAt,
    this.foundedYear,
    this.website,
    this.companySize,
    this.companyType,
    this.industry,
    this.aboutCompany,
    this.linkedinUrl,
    this.facebookUrl,
    this.instagramUrl,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    partnerId = json['partner_id']?.toString();
    name = json['name']?.toString();
    address = json['address']?.toString();
    lat = json['lat']?.toString();
    lng = json['lng']?.toString();
    radius = json['radius'] is num ? json['radius'] : num.tryParse(json['radius']?.toString() ?? '');
    managerId = json['manager_id'];
    status = json['status']?.toString();
    companyLogo = json['company_logo']?.toString();
    gstNumber = json['gst_number']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    foundedYear = json['founded_year']?.toString();
    website = json['website']?.toString();
    companySize = json['company_size']?.toString();
    companyType = json['company_type']?.toString();
    industry = json['industry']?.toString();
    aboutCompany = json['about_company']?.toString();
    linkedinUrl = json['linkedin_url']?.toString();
    facebookUrl = json['facebook_url']?.toString();
    instagramUrl = json['instagram_url']?.toString();
  }
}
