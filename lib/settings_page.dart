import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_jk/flutter_jk.dart';

import 'my_private_data.dart';

typedef DarkModeCallback = void Function(bool darkMode);
typedef SettingChangeCallback = void Function(String name, dynamic value);

class SettingsPage extends StatefulWidget {
  final DarkModeCallback onToggleDarkMode;
  final SettingChangeCallback onSettingChange;
  bool keepTheScreenOn = false;
  bool showExampleNoiseLevel = true;

  SettingsPage(
      {this.onToggleDarkMode,
      this.onSettingChange,
      this.keepTheScreenOn,
      this.showExampleNoiseLevel});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _fireChange(final String name, dynamic value) {
    if (widget.onSettingChange != null) {
      widget.onSettingChange(name, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            //title: 'Section',
            tiles: [
              SettingsTile.switchTile(
                leading: Icon(Icons.brightness_6),
                title: 'dark mode'.tr,
                switchValue: Theme.of(context).brightness == Brightness.dark,
                onToggle: widget.onToggleDarkMode,
              ),
              SettingsTile.switchTile(
                  leading: Icon(Icons.settings_brightness),
                  title: 'keep the screen on'.tr,
                  onToggle: (value) {
                    _fireChange('keep the screen on', value);
                    setState(() {
                      widget.keepTheScreenOn = value;
                    });
                  },
                  switchValue: widget.keepTheScreenOn),
              SettingsTile.switchTile(
                  leading: Icon(Icons.live_help),
                  title: 'show example noise level'.tr,
                  onToggle: (value) {
                    _fireChange('show example noise level', value);
                    setState(() {
                      widget.showExampleNoiseLevel = value;
                    });
                  },
                  switchValue: widget.showExampleNoiseLevel),
              SettingsTile(
                  leading: Icon(Icons.rate_review),
                  title: 'rate review'.tr,
                  onTap: () => _launch(MyPrivateData.playStoreUrl)),
              SettingsTile(
                  leading: Icon(Icons.share),
                  title: 'share app'.tr,
                  onTap: () => Share.share(MyPrivateData.playStoreUrl)),
              SettingsTile(
                  leading: Icon(Icons.apps),
                  title: 'more apps'.tr,
                  onTap: () =>
                      _launch(MyPrivateData.googlePlayDeveloperPageUrl)),
              SettingsTile(
                leading: Icon(Icons.info_outline),
                title: 'app info'.tr,
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

  void _launch(final String text) async {
    if (await canLaunch(text)) {
      await launch(text);
    }
  }
}
