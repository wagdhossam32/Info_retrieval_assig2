import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  Future<void> _enrollInCourse(String courseId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
      'enrolledUsers': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final coursesRef = FirebaseFirestore.instance.collection('courses');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/addCourse'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: coursesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No courses yet'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final desc = data['description'] ?? '';

              return ListTile(
                title: Text(title),
                subtitle: Text(desc),
                trailing: ElevatedButton(
                  onPressed: () => _enrollInCourse(doc.id),
                  child: const Text('Enroll'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}