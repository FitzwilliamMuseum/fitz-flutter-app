import 'package:dio/dio.dart';
import '../models/3d_model.dart';
import '../utilities/constants.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();
  final client = Dio(
    BaseOptions(
      baseUrl: Constants.BASE_URL,
      queryParameters: {
      },
    ),
  );

  Future<ThreeDModel?> getModelDetails(int movieId) async {
    print(movieId);
    final response = await client.get(
      "app_3d_models?fields=*.*.*.*&sort=-id&limit=1&filter[id][eq]=$movieId",
    );
    if (response.statusCode == 200) {
      print(response.data);
      return ThreeDModel.fromJson(response.data);
    }
    return null;
  }
}