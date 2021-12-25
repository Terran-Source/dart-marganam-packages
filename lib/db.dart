library dart_marganam.db;

export 'db/custom_query.dart';
export 'db/drift/dao_mixin.dart';
// ! TODO: *TEST* the following platform specific export
export 'db/drift/open_connection.dart'
    if (dart.library.html) 'db/drift/openConnection/web.dart'
    if (dart.library.io) 'db/drift/openConnection/native.dart'
    // ? doubtful if it ever reaches
    if (dart.library.core) 'db/drift/openConnection/memory.dart';
export 'db/enums.dart';
export 'db/query_set.dart';
