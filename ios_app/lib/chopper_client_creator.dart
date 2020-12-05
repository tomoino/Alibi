import 'package:chopper/chopper.dart';

class ChopperClientCreator {
  static final String baseUrl = "https://alibi-api.herokuapp.com";

  static ChopperClient create() {
    return ChopperClient(
      baseUrl: ChopperClientCreator.baseUrl,
      converter: JsonConverter(),
    );
  }
}