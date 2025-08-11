import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/types_documents_controller.dart';
import 'package:test_app_divkit/me/models/types_documents_model.dart';

class StepThreeController {
  StepThreeController();

  final SyncController _syncController = SyncController.instance;

  late List<TypesDocuments> typesDocuments;

  Future<void> loadData() async {
    await _syncController.loadAll();

    typesDocuments =
        ((_syncController.getController(ControllerKey.typesDocuments)
                    as TypesDocumentsController)
                .items
            as List<TypesDocuments>?) ??
        [];
  }
}
