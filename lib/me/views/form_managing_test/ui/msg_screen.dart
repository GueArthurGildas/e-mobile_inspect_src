// lib/models/message.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_Inspection_APP/me/controllers/user_controller.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/msg_service_user.dart';

// lib/widgets/send_message_box.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';

const kOrange    = Color(0xFFFF6A00);
const kDeepGreen = Color(0xFF2ECC71);

final chatBubbleMe    = kOrange.withOpacity(.15);
final chatBubbleOther = const Color(0xFFF5F6FA);


class Message {
  final String id;
  final int senderId;
  final String senderName;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final List<Map<String, dynamic>> senderRoles;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    required this.senderRoles,
  });

  /// Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderRoles': senderRoles,
    };
  }

  /// Créer un Message depuis Firestore
  factory Message.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? 0,
      senderName: data['senderName'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      senderRoles: List<Map<String, dynamic>>.from(data['senderRoles'] ?? []),
    );
  }
}



class SendMessageBox extends StatefulWidget {
  const SendMessageBox({super.key});

  @override
  State<SendMessageBox> createState() => _SendMessageBoxState();
}

class _SendMessageBoxState extends State<SendMessageBox> {
  final _ctrl = TextEditingController();
  final _service = MessageService();
  bool _sending = false;

  Future<void> _onSend() async {
    final userCtrl = context.read<UserController>();
    final u = userCtrl.currentUser;

    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun utilisateur connecté.")),
      );
      return;
    }
    if (_ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Écris un message avant d'envoyer.")),
      );
      return;
    }

    try {
      setState(() => _sending = true);

      // Transforme les rôles du User en array<Map>
      final roles = (u.jsonRole ?? [])
          .map((r) => {"name": (r.name ?? "").toString()})
          .toList();

      final msg = Message(
        id: const Uuid().v4(),
        senderId: u.id ?? 0,
        senderName: (u.name ?? '').trim(),
        senderEmail: (u.email ?? '').trim().toLowerCase(), // <-- normalisé
        message: _ctrl.text.trim(),
        timestamp: DateTime.now(),
        senderRoles: roles,
      );

      await _service.sendMessage(msg);

      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message envoyé ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur d’envoi : $e")),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: "Écrire un message…",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            minLines: 1,
            maxLines: 4,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          icon: _sending
              ? const SizedBox(
            height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.send),
          onPressed: _sending ? null : _onSend,
          label: const Text("Envoyer"),
        ),
      ],
    );
  }
}



// lib/widgets/message_bubble.dart
class MessageBubble extends StatelessWidget {
  final String text;
  final String senderName;
  final bool isMe;
  final DateTime time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final ts = TimeOfDay.fromDateTime(time).format(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) // ✅ Affiche le nom seulement si ce n’est pas moi
              Text(
                senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              ts,
              style: TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
