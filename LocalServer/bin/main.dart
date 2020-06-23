import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:mime_type/mime_type.dart';

Future main() async {
  var server = await HttpServer.bind(
    '127.0.0.1',
    80,
  );
  print('Listening on ${server.address}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.method == 'POST') {
      request.response.headers.set('Content-Type', 'json');
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers
          .add('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');
      var json = await utf8.decoder.bind(request).join();
      await File('bin/data/network.json').writeAsString(json);
      await request.response.close();
    } else {
      print(
          'Server access!\nInfo: ${request.connectionInfo.remoteAddress}:${request.connectionInfo.remotePort}');
      print('${request.uri.toFilePath()}');

      final path = request.uri.toFilePath();
      final resultPath = path == '/' ? '/index.html' : path;

      final file =
          File('${File(Platform.script.toFilePath()).parent.path}$resultPath');

      if (file.existsSync()) {
        var mimeType = mime(path);
        mimeType ??= 'text/plain';
        request.response.headers.set('Content-Type', mimeType);
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers
            .add('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');

        var openedFile = file.openSync();
        request.response.contentLength = openedFile.lengthSync();
        openedFile.closeSync();
        await file.openRead().pipe(request.response).then((v) {
          print('closed');
          request.response.close();
        });
      }
    }
  }
}
