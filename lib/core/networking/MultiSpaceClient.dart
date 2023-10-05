import 'dart:math';

import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class MultiSpaceClient {
  final Web3Client _client;

  static final MultiSpaceClient _instance = MultiSpaceClient._internal();
  factory MultiSpaceClient() => _instance;

  MultiSpaceClient._internal()
      : _client = Web3Client(
          Env.eth_url,
          LoggingClient(Client()),
          socketConnector: () {
            return IOWebSocketChannel.connect(Env.eth_ws).cast<String>();
          },
        );

  Web3Client get client => _client;
}

class LoggingClient extends BaseClient {
  final Client _inner;
  int _counter = 0;

  LoggingClient(this._inner);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    _counter++;
    // if (request is Request) {
    //   print('sending ${request.url} with ${request.body}');
    // } else {
    //   print('sending ${request.url}');
    // }
    await Future.delayed(Duration(milliseconds: Random().nextInt(500)));
    final response = await _inner.send(request);
    final read = await Response.fromStream(response);

    // print('response:\n${read.body}');

    return StreamedResponse(
        Stream.fromIterable([read.bodyBytes]), response.statusCode);
  }
}
