library marganam.db.drift.open_connection;

// ! TODO: *TEST* the following platform specific export
export 'openConnection/open_connection_stub.dart'
    if (dart.library.html) 'openConnection/web.dart'
    if (dart.library.io) 'openConnection/native.dart'
    // ? doubtful if it ever reaches
    if (dart.library.core) 'openConnection/memory.dart';
