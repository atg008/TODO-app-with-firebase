import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreServices firestoreServices = FirestoreServices();
  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog box to add note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (docID == null) {
                      firestoreServices.addNote(textController.text);
                    } else {
                      firestoreServices.updateNote(docID, textController.text);
                    }
                    textController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 175, 127, 184),
          title: const Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreServices.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get each individual doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get note from each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // display as a tile
                  return Card(
                    child: ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // update
                            IconButton(
                                onPressed: () => openNoteBox(docID: docID),
                                icon: Icon(Icons.settings)),

                            // delete
                            IconButton(
                                onPressed: () =>
                                    firestoreServices.deleteNote(docID),
                                icon: Icon(Icons.delete)),
                          ],
                        )),
                  );
                });
          } else {
            return Text("No notes");
          }
        },
      ),
    );
  }
}
