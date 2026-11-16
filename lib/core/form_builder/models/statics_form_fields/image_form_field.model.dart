part of '../../../../omni_core.dart';

class ImageFormFieldModel extends StaticFormFieldModel {
  bool isStatic = true;
  String? data;
  BoxFit? fit;

  ImageFormFieldModel({
    this.data,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  ImageFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    data = AppBaseModel.parseString(json?['data']);
    fit = _parseFit(json?['fit']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    json['fit'] = fit?.name;
    return json;
  }

  static BoxFit? _parseFit(dynamic value) {
    if (value == null) return BoxFit.cover;
    switch (value.toString().toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }
}
