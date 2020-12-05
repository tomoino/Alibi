import "dart:async";
import 'package:chopper/chopper.dart';

// this is necessary for the generated code to find your class
part 'event_service.chopper.dart';

@ChopperApi(baseUrl: "")
abstract class EventService extends ChopperService {

  // helper methods that help you instantiate your service
  static EventService create([ChopperClient client]) => 
      _$EventService(client);

  @Get(path: '/event/{id}')
  Future<Response> getEventById(@Path() String id);

  // @Post(path: '/create')
  // Future<Response> createEvent(@Body() Map<String, dynamic> eventForm);

  @Post(path: '/update/{id}')
  Future<Response> updateEventById(@Path() String id, @Body() Map<String, dynamic> eventForm);
  
}