class Profile {
  final String brandName;
  final String termsAndConditions;
  final String? imageUrl;

  Profile({
    required this.brandName,
    required this.termsAndConditions,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'termsAndConditions': termsAndConditions,
        'imageUrl': imageUrl,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        brandName: json['brandName'] as String? ?? '',
        termsAndConditions: json['termsAndConditions'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
      );
}

