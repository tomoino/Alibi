// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$EventService extends EventService {
  _$EventService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = EventService;

  Future<Response> getEventById(String id) {
    final $url = '/event/${id}';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> updateEventById(String id, dynamic eventForm) {
    final $url = '/update/${id}';
    final $body = eventForm;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
