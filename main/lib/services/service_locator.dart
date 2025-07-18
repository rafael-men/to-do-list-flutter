import 'package:get_it/get_it.dart';
import 'package:main/utils/task_list_controller.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<  TaskListController>(() => TaskListController());
}