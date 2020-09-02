import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'my_local.dart';
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
                leading: Icon(Icons.brightness_6),
                title: lo('dark mode'),
                switchValue: Theme.of(context).brightness == Brightness.dark,
                onToggle: widget.onToggleDarkMode,
              ),
              SettingsTile.switchTile(
                  leading: Icon(Icons.settings_brightness),
                  title: lo('keep the screen on'),
                  onToggle: (value) {
                    _fireChange('keep the screen on', value);
                    setState(() {
                      widget.keepTheScreenOn = value;
                    });
                  },
                  switchValue: widget.keepTheScreenOn),
              SettingsTile.switchTile(
                  leading: Icon(Icons.live_help),
                  title: lo('show example noise level'),
                  onToggle: (value) {
                    _fireChange('show example noise level', value);
                    setState(() {
                      widget.showExampleNoiseLevel = value;
                    });
                  },
                  switchValue: widget.showExampleNoiseLevel),
              SettingsTile(
                  leading: Icon(Icons.rate_review),
                  title: lo('rate review'),
                  onTap: () => _launch(MyPrivateData.playStoreUrl)),
              SettingsTile(
                  leading: Icon(Icons.share),
                  title: lo('share app'),
                  onTap: () => Share.share(MyPrivateData.playStoreUrl)),
              SettingsTile(
                  leading: Icon(Icons.apps),
                  title: lo('more apps'),
                  onTap: () =>
                      _launch(MyPrivateData.googlePlayDeveloperPageUrl)),
              SettingsTile(
                leading: Icon(Icons.info_outline),
                title: lo('app info'),
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
