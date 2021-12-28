/// Implement corresponding functionality in `CustomQuery._load()`
enum ResourceFrom { asset, web }

enum CustomQueryType { defaultStartup, dataInitiation, openingPragma }

final Map<Type, List> enumTypes = {};

void extendDbEnumType<T>(List<T> values) {
  if (values is List<Enum> && !enumTypes.containsKey(T)) {
    enumTypes[T] = values;
  }
}
