import 'package:fdecibel/my_themedata.dart';
import 'package:fdecibel/shared_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

import 'my_local.dart';

typedef DarkModeCallback = void Function(bool darkMode);

class SettingsPage extends StatelessWidget {
  final DarkModeCallback onToggleDarkMode;

  SettingsPage({this.onToggleDarkMode});

  @override
  Widget build(BuildContext context) {
    final lo = MyLocal.of(context).text;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lo('settings'),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            //title: 'Section',
            tiles: [
              SettingsTile.switchTile(
                title: lo('dark mode'),
                switchValue: Theme.of(context).brightness == Brightness.dark,
                onToggle: onToggleDarkMode,
              ),
              SettingsTile(
                title: 'More Info',
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                      context: context,
                      applicationName: packageInfo.appName,
                      applicationVersion: packageInfo.version);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
