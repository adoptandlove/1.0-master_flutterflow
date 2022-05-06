import 'package:adoptandlove/analytics/dio_firebase_performance.dart';
import 'package:adoptandlove/authentication/authentication_manager.dart';
import 'package:adoptandlove/pets.dart';
import 'package:adoptandlove/preferences/app_preferences.dart';
import 'package:dio/dio.dart';

class PetsApiService {
  static final PetsApiService _singleton = new PetsApiService._internal();

  factory PetsApiService() {
    return _singleton;
  }

  static const _baseApiUrl = "https://adoptandlove.eu/api/";

  static const _authenticateUrl = "https://adoptandlove.eu/api/v1/authentication/firebase/connect/";

  final Dio rawDio = Dio();
  final Dio dio = Dio(BaseOptions(
    baseUrl: _baseApiUrl,
  ));

  final _appPreferences = AppPreferences();
  final _authenticationManager = AuthenticationManager();

  PetsApiService._internal() {
    dio.interceptors.add(
        InterceptorsWrapper(onRequest: (RequestOptions options, handler) async {
      final apiToken = await _appPreferences.getApiToken();

      if (apiToken != null) {
        _addHeaderApiToken(options.headers, apiToken);
      } else if (await _authenticationManager.isLoggedIn()) {
        try {
          // ignore: deprecated_member_use
          dio.interceptors.requestLock.lock();
          final idToken = await _authenticationManager.getIdToken();
          if (idToken != null) {
            final apiToken = await _authenticate(idToken);
            await _appPreferences.setApiToken(apiToken);

            _addHeaderApiToken(options.headers, apiToken);
          }
        } catch (ex) {
          print(ex);
        } finally {
          // ignore: deprecated_member_use
          dio.interceptors.requestLock.unlock();
        }
      }

      return handler.next(options);
    }, onResponse: (Response response, handler) {
      // Do something with response data
      return handler.next(response); // continue
    }, onError: (DioError e, handler) {
      // Do something with response error
      return handler.next(e); //continue
    }));

    dio.interceptors.add(DioFirebasePerformanceInterceptor());
    rawDio.interceptors.add(DioFirebasePerformanceInterceptor());
  }

  static _addHeaderApiToken(Map<String, dynamic> headers, String apiToken) {
    headers["Authorization"] = "Token $apiToken";
  }

  Future<String> _authenticate(String idToken) async {
    final response = await rawDio.post(
      _authenticateUrl,
      data: {
        "id_token": idToken,
      },
    );

    return response.data['key'];
  }

  Future<List<Pet>> generatePetsToSwipe(
    List<int> favoritePetIds,
    List<int> dislikedPetIds,
    PetType petType,
  ) async {
    final response = await dio.post(
      '/v1/pets/generate/',
      data: {
        "liked_pets": favoritePetIds,
        "disliked_pets": dislikedPetIds,
        "pet_type": petType.apiRepresentation,
      },
    );

    return response.data.map<Pet>((model) => Pet.fromJson(model)).toList();
  }

  Future likePet(Pet pet) async {
    await dio.put(
      '/v1/pets/pet/choice/',
      data: {
        "pet": pet.id,
        "is_favorite": true,
      },
    );
  }

  Future dislikePet(Pet pet) async {
    await dio.put(
      '/v1/pets/pet/choice/',
      data: {
        "pet": pet.id,
        "is_favorite": false,
      },
    );
  }

  Future shelterPet(Pet pet) async {
    await dio.put(
      "/v1/pets/pet/shelter/",
      data: {
        "pet": pet.id,
      },
    );
  }

  Future<List<Pet>> getPets(
      List<int> petIds, String lastUpdateDateIso8601) async {
    if (petIds.isEmpty) {
      return [];
    }

    final response = await dio.get(
      "/v2/pets/",
      queryParameters: {
        "pet_ids": petIds.join(','),
        "last_update": lastUpdateDateIso8601,
      },
    );

    final dogs = response.data['dogs'].map<Pet>((model) => Pet.fromJson(model));
    final cats = response.data['cats'].map<Pet>((model) => Pet.fromJson(model));

    return [...dogs, ...cats];
  }
}
