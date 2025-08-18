import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class LocalFileItem {
  final String path;

  String get name => path.split('/').last;
  bool isSelected;
  bool isSaved;
  int? size;
  dynamic type;

  LocalFileItem({
    required this.path,
    this.type,
    this.isSelected = false,
    this.isSaved = false,
    this.size,
  });
}

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({
    super.key,
    this.savedFiles,
    this.onPickFile,
    this.onUploadSelected,
    this.onDelete,
  });

  final List<LocalFileItem>? savedFiles;
  final Function(List<LocalFileItem> filesToUpload)? onUploadSelected;
  final Future<dynamic>? Function(List<LocalFileItem> files)? onPickFile;
  final Function(List<LocalFileItem> files)? onDelete;

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  final List<LocalFileItem> _pickedFiles = [];
  bool _isLoading = false;

  bool get allSelected =>
      _pickedFiles.isNotEmpty && _pickedFiles.every((file) => file.isSelected);
  bool get noneSelected => _pickedFiles.every((file) => !file.isSelected);
  int get selectedCount => _pickedFiles.where((file) => file.isSelected).length;

  void _toggleSelection(int index) {
    if (index < 0 || index >= _pickedFiles.length) return;
    setState(() {
      _pickedFiles[index].isSelected = !_pickedFiles[index].isSelected;
    });
  }

  void _selectAll() {
    setState(() {
      bool targetState = !allSelected;
      for (var file in _pickedFiles) {
        file.isSelected = targetState;
      }
    });
  }

  void _removeSelectedFiles() {
    setState(() {
      _pickedFiles.removeWhere((file) => file.isSelected);
    });

    widget.onDelete?.call(_pickedFiles);
  }

  Future<void> _pickFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        // allowedExtensions: ['jpg', 'pdf', 'doc', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        bool waitForResult = widget.onPickFile != null;
        dynamic res = await widget.onPickFile?.call(
          result.files
              .map((f) => LocalFileItem(path: f.path!, size: f.size))
              .toList(),
        );
        // waitForResult &= res is Future<dynamic> || res is Future<void>;

        if (waitForResult && res == null) {
          return;
        }

        setState(() {
          for (var loadedFile in result.files) {
            if (loadedFile.path != null) {
              if (!_pickedFiles.any(
                (existingFile) =>
                    LocalFileItem(path: existingFile.path).name ==
                    LocalFileItem(path: loadedFile.path!).name,
              )) {
                _pickedFiles.add(
                  LocalFileItem(path: loadedFile.path!, size: loadedFile.size, type: res),
                );
              } else {
                print('duplicate file');
              }
            } else {
              print('something');
            }
          }
        });
      } else {
        print('Aucun fichier selectionne.');
      }
    } catch (e) {
      print('Error picking files: $e');
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleUpload() {
    final filesToUpload = _pickedFiles
        .where((file) => file.isSelected)
        .toList();
    if (filesToUpload.isEmpty) {
      // print('No file picked for upload.');
      return;
    }

    widget.onUploadSelected?.call(filesToUpload);
    setState(() {
      for (var file in _pickedFiles) {
        file.isSelected = false;
        file.isSaved = true;
      }
    });
  }

  String _formatBytes(int bytes, int decimals) {
    // helper to format bytes to human readable format - gemini
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.savedFiles != null) {
      setState(() {
        _pickedFiles.addAll(widget.savedFiles!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFFF6A00),
                ),
                label: const Text(
                  'Ajouter',
                  style: TextStyle(color: Color(0xFFFF6A00)),
                ),
                onPressed: _isLoading ? null : _pickFiles,
              ),
              if (_pickedFiles.isNotEmpty)
                TextButton.icon(
                  icon: Icon(
                    allSelected ? Icons.deselect : Icons.select_all,
                    color: Colors.blue,
                  ),
                  label: Text(
                    allSelected ? 'Tout deselectionner' : 'Tout selectionner',
                  ),
                  onPressed: _selectAll,
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!_isLoading && _pickedFiles.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 56.0,
              ),
              child: Text(
                'Aucun fichier ajoute. Cliquez sur le bouton "Ajouter" pour ajouter des fichiers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        if (_pickedFiles.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                final fileItem = _pickedFiles[index];
                return GestureDetector(
                  onTap: () => _toggleSelection(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: fileItem.isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: fileItem.isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: ListTile(
                      leading: _getFileIcon(fileItem.name),
                      title: Row(
                        spacing: 10.0,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Text(
                                fileItem.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                           ),
                          Text(
                            fileItem.isSaved ? '(sauvegardé)' : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        fileItem.size != null
                            ? _formatBytes(fileItem.size!, 1)
                            : 'Taille inconnue',
                      ),
                      trailing: Checkbox(
                        value: fileItem.isSelected,
                        onChanged: (_) => _toggleSelection(index),
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Text(
              'Sauvegardez les fichiers avant de fermer',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        if (_pickedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(
                    Icons.delete_outline,
                    color: selectedCount > 0 ? Colors.red : Colors.grey,
                  ),
                  label: Text('Supprimer ($selectedCount)'),
                  style: TextButton.styleFrom(
                    foregroundColor: selectedCount > 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: selectedCount > 0 ? _removeSelectedFiles : null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text('Sauvegarder ($selectedCount)'),
                  onPressed:
                      selectedCount > 0 && widget.onUploadSelected != null
                      ? _handleUpload
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.orange, size: 32);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green, size: 32);
      default:
        return const Icon(
          Icons.insert_drive_file,
          color: Colors.grey,
          size: 32,
        );
    }
  }
}
