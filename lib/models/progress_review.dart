class ProgressReview {
  final String progressStepID;
  final int qualityScore;
  final bool isDesignAccurate;
  final bool isMaterialCorrect;
  final bool isColorCorrect;
  final bool isFunctionalityMet;
  final String customerComment;
  final DateTime? createdAt;
  final String? progressStepApprovalID;
  final int? totalScore;
  final bool? isPass;

  ProgressReview({
    required this.progressStepID,
    required this.qualityScore,
    required this.isDesignAccurate,
    required this.isMaterialCorrect,
    required this.isColorCorrect,
    required this.isFunctionalityMet,
    required this.customerComment,
    this.createdAt,
    this.progressStepApprovalID,
    this.totalScore,
    this.isPass,
  });

  factory ProgressReview.fromJson(Map<String, dynamic> json) {
    return ProgressReview(
      progressStepID: json['progressStepID'] ?? '',
      qualityScore: json['qualityScore'] ?? 0,
      isDesignAccurate: json['isDesignAccurate'] ?? false,
      isMaterialCorrect: json['isMaterialCorrect'] ?? false,
      isColorCorrect: json['isColorCorrect'] ?? false,
      isFunctionalityMet: json['isFunctionalityMet'] ?? false,
      customerComment: json['customerComment'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      progressStepApprovalID: json['progressStepApprovalID'],
      totalScore: json['totalScore'],
      isPass: json['isPass'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progressStepID': progressStepID,
      'qualityScore': qualityScore,
      'isDesignAccurate': isDesignAccurate,
      'isMaterialCorrect': isMaterialCorrect,
      'isColorCorrect': isColorCorrect,
      'isFunctionalityMet': isFunctionalityMet,
      'customerComment': customerComment,
    };
  }
}
