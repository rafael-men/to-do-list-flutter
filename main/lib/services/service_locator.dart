import 'package:get_it/get_it.dart';
import 'package:main/services/database_helper.dart';
import 'package:main/utils/task_list_controller.dart';
import 'package:main/utils/task_series_controller.dart';


final getIt = GetIt.instance;

void setupGetIt() {

  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);


  getIt.registerLazySingleton<TaskListController>(
    () => TaskListController(getIt<DatabaseHelper>()),
  );

  getIt.registerSingleton<TaskSeriesController>(TaskSeriesController(getIt<DatabaseHelper>()));

}