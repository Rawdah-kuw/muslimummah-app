import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/content.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('منارات', 'Beacons')),
          bottom: TabBar(
            labelColor: AppColors.sage700,
            indicatorColor: AppColors.sage600,
            tabs: const [
              Tab(text: 'YouTube'),
              Tab(text: 'Instagram'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _list(context, ContentRepo.youtube, Icons.play_circle_fill),
            _list(context, ContentRepo.instagram, Icons.camera_alt),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<Account> items, IconData icon) {
    // Featured / official accounts appear first (keeping their relative order).
    final ordered = [
      ...items.where((a) => a.feat || a.official),
      ...items.where((a) => !(a.feat || a.official)),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ordered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = ordered[i];
        return Card(
          child: ListTile(
            leading: Icon(icon, color: AppColors.sage700),
            title: Row(
              children: [
                Flexible(
                    child: Text(AppState.I.loc(a.name),
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                if (a.official || a.feat)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: Icon(Icons.verified,
                        size: 16, color: AppColors.sage600),
                  ),
              ],
            ),
            subtitle: Text(AppState.I.loc(a.subtitle),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.ios_share, size: 18),
                  tooltip: tr('مشاركة', 'Share'),
                  onPressed: () => shareText(
                      '${AppState.I.loc(a.name)}${a.handle.isNotEmpty ? '\n@${a.handle}' : ''}\n${a.url}\n\nمنارات — أمة الإسلام'),
                ),
                const Icon(Icons.open_in_new, size: 18),
              ],
            ),
            onTap: () => openUrl(context, a.url),
          ),
        );
      },
    );
  }
}
