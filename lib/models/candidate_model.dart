class CandidateModel {
  final String candidateId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String email;
  final String phone;
  final int gender; // 0 for male, 1 for female, 2 for other
  final String jobTitle;
  final List<String> skills;
  final int experience;

  CandidateModel({
    required this.candidateId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.gender,
    required this.jobTitle,
    required this.skills,
    required this.experience,
  });

  Map<String, dynamic> toJson() {
    return {
      'candidateId': candidateId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phone': phone,
      'gender': gender,
      'jobTitle': jobTitle,
      'skills': skills,
      'experience': experience,
    };
  }

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      candidateId: json['candidateId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      gender: json['gender'] as int,
      jobTitle: json['jobTitle'] as String,
      skills: List<String>.from(json['skills'] as List),
      experience: json['experience'] as int,
    );
  }

  // Example candidate data
  static CandidateModel get example => CandidateModel(
        candidateId: 'C123456',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: '1990-01-01',
        email: 'john.doe@example.com',
        phone: '+91 9876543210',
        gender: 0,
        jobTitle: 'Software Engineer',
        skills: ['Angular', 'React.js', 'SQL'],
        experience: 5,
      );
}
