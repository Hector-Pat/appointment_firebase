import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;

  const DoctorProfilePage({super.key, required this.doctorId});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser!;

  // 🔹 Abre el mismo diálogo de agendar cita, con el doctor ya seleccionado
  Future<void> _showAppointmentDialog(Map<String, dynamic> doctorData) async {
    final TextEditingController motivoCtrl = TextEditingController();
    final TextEditingController fechaCtrl = TextEditingController();
    final TextEditingController horaCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Agendar cita con ${doctorData['nombre']}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: motivoCtrl,
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fechaCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Fecha (seleccionar)'),
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
                  decoration:
                      const InputDecoration(labelText: 'Hora (HH:mm)'),
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
                if (motivoCtrl.text.isEmpty ||
                    fechaCtrl.text.isEmpty ||
                    horaCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Completa todos los campos.'),
                  ));
                  return;
                }

                final data = {
                  'doctor': doctorData['nombre'],
                  'motivo': motivoCtrl.text.trim(),
                  'fecha': fechaCtrl.text.trim(),
                  'hora': horaCtrl.text.trim(),
                  'uid': _user.uid,
                };

                await _firestore.collection('appointments').add(data);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Cita agendada correctamente.')));
              },
              child: const Text('Agendar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('doctores').doc(widget.doctorId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doctor = snapshot.data!;
        final data = doctor.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(title: Text(data['nombre'])),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nombre'],
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Especialidad: ${data['especialidad']}'),
                Text('Correo: ${data['correo']}'),
                Text('Teléfono: ${data['telefono']}'),
                const SizedBox(height: 16),
                const Text(
                  'Horarios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                // 🔹 Muestra los horarios disponibles por día
                if (data['horarios'] != null)
                  ...data['horarios'].entries.map<Widget>((entry) {
                    final dia = entry.key;
                    final horas = List<String>.from(entry.value);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('$dia: ${horas.join(", ")}'),
                    );
                  }),

                const Spacer(),

                // 🔹 Botón de agendar cita
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Agendar cita'),
                    onPressed: () => _showAppointmentDialog(data),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
