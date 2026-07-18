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
          title: Text(tr('حسابات موصى بها', 'Recommended Accounts')),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = items[i];
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
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openUrl(context, a.url),
          ),
        );
      },
    );
  }
}
