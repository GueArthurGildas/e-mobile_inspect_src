import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_Inspection_APP/me/controllers/user_controller.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/message/service_chat.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/msg_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  bool _isNewDay(DateTime? prev, DateTime curr) {
    if (prev == null) return true;
    return prev.year != curr.year ||
        prev.month != curr.month ||
        prev.day != curr.day;
  }

  String _formatDayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = that.difference(today).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == -1) return "Hier";
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  Widget _dateSeparator(DateTime d) {
    final label = _formatDayLabel(d);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.88),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(thickness: 1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          titleSpacing: 0,
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF6A00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Conversation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: .2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Centre de communication",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  tooltip: 'Options',
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // --- IMAGE DE FOND ---
          Positioned.fill(
            child: Image.asset(
              "assets/me/images/fond_screen.png",
              fit: BoxFit.cover,
            ),
          ),

          // --- CONTENU CHAT ---
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(.08), // voile semi-transparent
                  child: StreamBuilder<List<Message>>(
                    stream: MessageService().streamAll(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text("Erreur: ${snap.error}"));
                      }
                      final items = snap.data ?? [];

                      if (items.isEmpty) {
                        return const Center(
                          child: Text("Aucune conversation pour le moment."),
                        );
                      }

                      DateTime? lastDate;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final m = items[i];
                          final dt = m.timestamp;
                          final newDay = _isNewDay(lastDate, dt);
                          lastDate = dt;

                          String _norm(String? s) => (s ?? '').trim().toLowerCase();
                          final meEmail = _norm(user?.email);
                          final isMe = _norm(m.senderEmail) == meEmail;

                          Widget bubble = MessageBubble(
                            text: m.message,
                            senderName: m.senderName,
                            isMe: isMe,
                            time: m.timestamp,
                          );

                          if (isMe) {
                            bubble = Dismissible(
                              key: ValueKey(m.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.red.withOpacity(.12),
                                child: const Icon(Icons.delete_outline),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Supprimer ce message ?"),
                                    content: const Text("Cette action est irréversible."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text("Annuler"),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text("Supprimer"),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                              },
                              onDismissed: (_) async {
                                await MessageService().deleteMessage(m.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Message supprimé.")),
                                );
                              },
                              child: bubble,
                            );
                          }

                          final header = newDay ? _dateSeparator(dt) : const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [header, bubble],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Zone d'envoi
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 6, 8, 12),
                child: SendMessageBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
