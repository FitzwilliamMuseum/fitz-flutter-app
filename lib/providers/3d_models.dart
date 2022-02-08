import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/3d_model.dart';
import '../services/apiservice.dart';

final modelDetailsProvider =
FutureProvider.autoDispose.family<ThreeDModel?, int>((_, modelID) {
  return ApiService.instance.getModelDetails(modelID);
});
