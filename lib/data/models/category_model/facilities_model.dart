class FacilityModel {
  final String? label;
  final String? value;
  final String? fieldType;

  FacilityModel({
    this.label,
    this.value,
    this.fieldType,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      label: json['label']?.toString(),
      value: json['value']?.toString(),
      fieldType: json['field_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'field_type': fieldType,
    };
  }

  bool get isChecked => value == "1";
}
