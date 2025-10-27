import 'package:cloud_firestore/cloud_firestore.dart';
// este archivo agrega doctores iniciales a Firestore, se activa desde main.dart
Future<void> addInitialDoctors() async {
  final firestore = FirebaseFirestore.instance;

  final doctores = [
    {
      'nombre': 'Dr. Carlos Pérez',
      'especialidad': 'Dermatología',
      'correo': 'carlos.perez@hospital.com',
      'telefono': '+52 999 123 4567',
      'activo': true,
      'horarios': {
        'lunes': ['09:00', '11:00', '15:00'],
        'miércoles': ['10:00', '12:00', '16:00'],
        'viernes': ['09:00', '13:00', '15:30'],
      },
    },
    {
      'nombre': 'Dra. Laura Gómez',
      'especialidad': 'Cardiología',
      'correo': 'laura.gomez@hospital.com',
      'telefono': '+52 998 456 7890',
      'activo': true,
      'horarios': {
        'martes': ['09:30', '11:30', '14:30'],
        'jueves': ['10:00', '12:00', '15:00'],
      },
    },
    {
      'nombre': 'Dr. Andrés Torres',
      'especialidad': 'Pediatría',
      'correo': 'andres.torres@hospital.com',
      'telefono': '+52 997 234 5678',
      'activo': true,
      'horarios': {
        'lunes': ['09:00', '10:30'],
        'miércoles': ['13:00', '15:00'],
      },
    },
    {
      'nombre': 'Dra. Sofía Rivas',
      'especialidad': 'Traumatología',
      'correo': 'sofia.rivas@hospital.com',
      'telefono': '+52 996 876 5432',
      'activo': true,
      'horarios': {
        'martes': ['09:00', '10:00', '11:00'],
        'jueves': ['13:00', '15:00'],
      },
    },
    {
      'nombre': 'Dr. Miguel Hernández',
      'especialidad': 'Medicina General',
      'correo': 'miguel.hernandez@hospital.com',
      'telefono': '+52 995 654 3210',
      'activo': true,
      'horarios': {
        'lunes': ['08:00', '09:00', '10:00'],
        'miércoles': ['14:00', '15:00'],
        'viernes': ['09:00', '11:00'],
      },
    },
  ];

  for (final doctor in doctores) {
    await firestore.collection('doctores').add(doctor);
  }

  print('✅ Doctores agregados correctamente');
}

// esto se escribe en las reglas de firebase para permitir que se ejecute sin iniciar sesión
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Permitir todo temporalmente
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
*/