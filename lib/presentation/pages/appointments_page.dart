import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser!;

  // 🔹 Función que valida conflictos antes de guardar
  Future<bool> _hasConflict({
    required String doctorName,
    required String fecha,
    required String hora,
  }) async {
    final appointmentsRef = _firestore.collection('appointments');

    // 1️⃣ Conflicto: mismo usuario, misma fecha y hora
    final userConflict = await appointmentsRef
        .where('uid', isEqualTo: _user.uid)
        .where('fecha', isEqualTo: fecha)
        .where('hora', isEqualTo: hora)
        .get();

    if (userConflict.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ya tienes una cita a esa hora.'),
      ));
      return true;
    }

    // 2️⃣ Conflicto: mismo doctor, misma fecha y hora
    final doctorConflict = await appointmentsRef
        .where('doctor', isEqualTo: doctorName)
        .where('fecha', isEqualTo: fecha)
        .where('hora', isEqualTo: hora)
        .get();

    if (doctorConflict.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('El doctor ya tiene una cita a esa hora.'),
      ));
      return true;
    }

    return false;
  }

  // 🔹 Diálogo para crear o editar cita
  Future<void> _showAppointmentDialog({DocumentSnapshot? doc}) async {
    final TextEditingController motivoCtrl =
        TextEditingController(text: doc?['motivo'] ?? '');
    final TextEditingController fechaCtrl =
        TextEditingController(text: doc?['fecha'] ?? '');
    final TextEditingController horaCtrl =
        TextEditingController(text: doc?['hora'] ?? '');

    String? _selectedDoctorId;
    String? _selectedDoctorName;

    // Cargar doctores activos
    final doctoresSnapshot = await _firestore
        .collection('doctores')
        .where('activo', isEqualTo: true)
        .get();
    final doctores = doctoresSnapshot.docs;

    QueryDocumentSnapshot<Map<String, dynamic>>? existingDoctor;
    if (doc != null && doctores.isNotEmpty) {
      try {
        existingDoctor =
            doctores.firstWhere((d) => d['nombre'] == doc['doctor']);
      } catch (_) {
        existingDoctor = doctores.first;
      }
    }

    if (existingDoctor != null) {
      _selectedDoctorId = existingDoctor.id;
      _selectedDoctorName = existingDoctor['nombre'];
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(doc == null ? 'Nueva cita' : 'Editar cita'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: const InputDecoration(labelText: 'Doctor'),
                  items: doctores.map((d) {
                    return DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(d['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selected =
                        doctores.firstWhere((d) => d.id == value);
                    setState(() {
                      _selectedDoctorId = value;
                      _selectedDoctorName = selected['nombre'];
                    });
                  },
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: motivoCtrl,
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: fechaCtrl,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: 'Fecha (seleccionar)'),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: Navigator.of(context, rootNavigator: true).context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 30)),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) {
                      fechaCtrl.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    }
                  },
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                  keyboardType: TextInputType.datetime,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDoctorName == null ||
                    motivoCtrl.text.isEmpty ||
                    fechaCtrl.text.isEmpty ||
                    horaCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Completa todos los campos.'),
                  ));
                  return;
                }

                // 🔍 Validar conflictos antes de guardar
                final hasConflict = await _hasConflict(
                  doctorName: _selectedDoctorName!,
                  fecha: fechaCtrl.text.trim(),
                  hora: horaCtrl.text.trim(),
                );

                if (hasConflict) return; // Si hay conflicto, detener aquí

                final data = {
                  'doctor': _selectedDoctorName,
                  'motivo': motivoCtrl.text.trim(),
                  'fecha': fechaCtrl.text.trim(),
                  'hora': horaCtrl.text.trim(),
                  'uid': _user.uid,
                };

                if (doc == null) {
                  await _firestore.collection('appointments').add(data);
                } else {
                  await _firestore
                      .collection('appointments')
                      .doc(doc.id)
                      .update(data);
                }

                if (mounted) Navigator.pop(context);
              },
              child: Text(doc == null ? 'Guardar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Eliminar cita
  Future<void> _deleteAppointment(String id) async {
    await _firestore.collection('appointments').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsStream = _firestore
        .collection('appointments')
        .where('uid', isEqualTo: _user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final citas = snapshot.data?.docs ?? [];

          if (citas.isEmpty) {
            return const Center(child: Text('No tienes citas registradas.'));
          }

          return ListView.builder(
            itemCount: citas.length,
            itemBuilder: (_, i) {
              final cita = citas[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(cita['doctor']),
                  subtitle: Text(
                      '${cita['motivo']}\n${cita['fecha']} - ${cita['hora']}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _showAppointmentDialog(doc: cita);
                      if (value == 'delete') _deleteAppointment(cita.id);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppointmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
