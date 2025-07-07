import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../services/auth_service.dart';
import '../widgets/note_card.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load notes once when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          IconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AuthService().signOut();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.notes.isEmpty) {
            return const Center(
              child: Text("Nothing here yet—tap ➕ to add a note."),
            );
          }

          return ListView.builder(
            itemCount: noteProvider.notes.length,
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];
              return NoteCard(
                note: note,
                onEdit: () {
                  _showNoteDialog(
                    context,
                    isEdit: true,
                    noteId: note.id,
                    existingText: note.text,
                  );
                },
                onDelete: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await noteProvider.deleteNote(note.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Note deleted")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNoteDialog(
      BuildContext context, {
        bool isEdit = false,
        String? noteId,
        String? existingText,
      }) {
    final noteCtrl = TextEditingController(text: existingText);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? "Edit Note" : "Add Note"),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            hintText: "Enter your note...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text("Please enter some text")),
                );
                return;
              }

              final noteProvider = context.read<NoteProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              try {
                if (isEdit && noteId != null) {
                  await noteProvider.updateNote(noteId, noteCtrl.text.trim());
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Note updated")),
                    );
                  }
                } else {
                  await noteProvider.addNote(noteCtrl.text.trim());
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Note added")),
                    );
                  }
                }
                navigator.pop();
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
