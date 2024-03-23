import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:notes/models/notes.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  //Initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [NotesSchema],
      directory: dir.path,
    );
  }

//list of nodes
  final List<Notes> currentNotes = [];

  //create a new node and save to db
  Future<void> addNote(String textFromUser) async {
    //create a new node object
    final newNote = Notes()..text = textFromUser;

    //save to db
    await isar.writeTxn(() => isar.notes.put(newNote));

    //re-read from databse
    await fetchNotes();
  }

//read databse
  Future<void> fetchNotes() async {
    List<Notes> fetchNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchNotes);
    notifyListeners();
  }

//update database
Future<void> updateNote(int id, String newText) async{
    final existingNote=await isar.notes.get(id);
    if(existingNote!=null){
      existingNote.text=newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
}

//delete database
Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
}
}
