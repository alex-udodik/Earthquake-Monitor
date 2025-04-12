import 'package:flutter/material.dart';

void showSettingsPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      return Stack(
        children: [
          Positioned(
            top: 80,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    SwitchListTile(
                      value: true,
                      onChanged: (val) {},
                      activeColor: Colors.tealAccent,
                      title: const Text("Earthquake Monitor",
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        "Tracking earthquakes in near real-time",
                        style:
                            TextStyle(color: Colors.tealAccent, fontSize: 12),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                      title: const Text("Language",
                          style: TextStyle(color: Colors.white)),
                      trailing: const Text("English",
                          style: TextStyle(color: Colors.white70)),
                    ),
                    ListTile(
                      title: const Text("Change theme",
                          style: TextStyle(color: Colors.white)),
                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white),
                          SizedBox(width: 8),
                          Icon(Icons.dark_mode, color: Colors.white),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text("Color blind mode",
                          style: TextStyle(color: Colors.white)),
                      trailing: Switch(value: false, onChanged: (_) {}),
                    ),
                    const Divider(color: Colors.grey),
                    const ListTile(
                      title: Text("About Earthquake App",
                          style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.expand_more, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
