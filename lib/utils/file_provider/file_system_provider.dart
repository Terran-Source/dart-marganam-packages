library marganam.utils.file_system_provider;

// ! TODO: *TEST* the following platform specific export
export 'file_system_provider/file_system_provider_stub.dart'
    if (dart.library.html) 'file_system_provider/memory.dart'
    if (dart.library.io) 'file_system_provider/native.dart';
