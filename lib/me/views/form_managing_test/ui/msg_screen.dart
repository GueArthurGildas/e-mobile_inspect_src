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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFFF6A00)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ NOM DE L'EXPÉDITEUR MIS EN ÉVIDENCE
              if (!isMe) ...[
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800, // ✅ Très gras
                    color: Color(0xFFFF6A00), // ✅ Couleur orange distinctive
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6), // ✅ Espacement entre nom et message
              ],

              // MESSAGE
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500, // ✅ Moins gras que le nom
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              // HEURE
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
