// lib/services/message_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/msg_screen.dart';


class MessageService {
  final _col = FirebaseFirestore.instance.collection('messages');

  Stream<List<Message>> streamAll() {
    return _col.orderBy('timestamp', descending: false).snapshots()
        .map((s) => s.docs.map((d) => Message.fromDoc(d)).toList());
  }

  Future<void> sendMessage(Message msg) async {
    await _col.doc(msg.id).set(msg.toMap());
  }

  Future<void> deleteMessage(String messageId) async {
    await _col.doc(messageId).delete();
  }
}
