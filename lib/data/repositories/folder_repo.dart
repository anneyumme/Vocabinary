import 'package:vocabinary/models/data/folder.dart';
import 'package:vocabinary/services/firebase/firestore_service.dart';

class FolderRepo {
  final _firestoreService = FirestoreService.instance;

  static String collectionPath(String userID) => 'users/$userID/folders';
  static String documentPath(String userID, String id) =>
      'users/$userID/folders/$id';

  Future<FolderModel?> getFolder(String userID, String id) =>
      folderStream(userID, id).first;

  Future<bool> addTopicToFolder(String userID, String folderID, String topicID) async {
    final folder = await getFolder(userID, folderID);
    if (folder != null) {
      folder.topicIDs.add(topicID);
      return updateFolder(userID, folderID, folder);
    }
    return false;
  }

  Future<List<FolderModel>> getFolders(String userID) =>
      foldersStream(userID).first;

  Future<String?> createFolder(String userID, FolderModel data) =>
      _firestoreService.createData(
        collectionPath: collectionPath(userID),
        data: data.toMap(),
      );
  Future<FolderModel> getFolderByTopicID(String userID, String topicID) async {
    final folders = await getFolders(userID);
    //find if topic id is in any folder contain topic array
    final folder = folders.firstWhere(
      (folder) => folder.topicIDs.contains(topicID),
      orElse: () => FolderModel(),
    );
    return folder;
  }

  Future<bool> updateFolder(
    String userID,
    String id,
    FolderModel data,
  ) =>
      _firestoreService.updateData(
        documentPath: documentPath(userID, id),
        data: data.toMap(),
      );

  Future<bool> deleteFolder(String userID, String id) =>
      _firestoreService.deleteData(documentPath: documentPath(userID, id));

  Stream<List<FolderModel>> foldersStream(String userID) =>
      _firestoreService.collectionStream<FolderModel>(
        path: collectionPath(userID),
        builder: _builder,
      );

  Stream<FolderModel?> folderStream(String userID, String id) =>
      _firestoreService.documentStream<FolderModel?>(
        path: documentPath(userID, id),
        builder: _builder,
      );

  Future<FolderModel?> _builder(
    Map<String, dynamic>? data,
    String documentID,
  ) async =>
      data != null ? FolderModel.fromMap(data, documentID) : null;
}
