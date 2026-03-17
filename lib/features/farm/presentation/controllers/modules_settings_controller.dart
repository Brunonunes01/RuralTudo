import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/modules_config.dart';

class ModulesSettingsController
    extends StateNotifier<AsyncValue<ModulesConfig>> {
  ModulesSettingsController(this._datasource)
    : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getModulesConfig);
  }

  Future<void> setProfile(String mode) async {
    await _datasource.setProfileMode(mode);
    await load();
  }

  Future<void> setModule(String key, bool active) async {
    await _datasource.setModuleActive(moduleKey: key, isActive: active);
    await load();
  }
}
