class ModulesConfig {
  ModulesConfig({required this.profileMode, required this.activeModules});

  final String profileMode;
  final Map<String, bool> activeModules;

  bool isActive(String key) => activeModules[key] ?? false;
}
