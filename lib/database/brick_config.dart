// import 'package:brick_offline_first/brick_offline_first.dart';
// import 'package:brick_rest/brick_rest.dart';
// import 'package:brick_sqlite/brick_sqlite.dart';
// import 'package:sqflite/sqflite.dart';
//
// @OfflineFirstWithRestSerializable()
// class BrickConfig {
//   static Future<OfflineFirstWithRestRepository> initialize() async {
//     final sqliteProvider = SqliteProvider(
//       'myapp.sqlite',
//       databaseFactory: databaseFactory,
//     );
//
//     final restProvider = RestProvider(
//       'YOUR_SUPABASE_URL/rest/v1',
//       modelDictionary: restModelDictionary,
//     );
//
//     return OfflineFirstWithRestRepository(
//       sqliteProvider: sqliteProvider,
//       restProvider: restProvider,
//       migrations: migrations,
//       offlineRequestQueue: RestRequestSqliteCache(),
//     );
//   }
// }