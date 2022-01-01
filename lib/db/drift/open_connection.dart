library marganam.db.drift.open_connection;

// ! TODO: *TEST* the following platform specific export
export 'open_connection/open_connection_stub.dart'
    if (dart.library.html) 'open_connection/web.dart'
    if (dart.library.io) 'open_connection/native.dart'
    // ? doubtful if it ever reaches
    if (dart.library.core) 'open_connection/memory.dart';
