import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room_model.dart';
import '../services/supabase_service.dart';

class BookingFormScreen extends StatefulWidget {
  final RoomModel room;

  const BookingFormScreen({super.key, required this.room});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _organizationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _participantController = TextEditingController(text: '10');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  bool _isLoading = false;

  @override
  void dispose() {
    _organizationController.dispose();
    _purposeController.dispose();
    _participantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai harus setelah waktu mulai')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil Supabase Edge Function `create-reservation`
      final result = await SupabaseService.createReservationViaEdgeFunction(
        roomId: widget.room.id,
        startTime: startDateTime,
        endTime: endDateTime,
        purpose: _purposeController.text.trim(),
        organization: _organizationController.text.trim(),
        participantCount: int.parse(_participantController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (!mounted) return;

      final resvId = result['data']?['id'] ?? 'RB-NEW';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Pengajuan Berhasil! 🎉'),
          content: Text(
            'Kode Reservasi: $resvId\n\nPengajuan Anda telah diterima dan diteruskan ke Admin untuk persetujuan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking: ${widget.room.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kapasitas Maksimal: ${widget.room.capacity} Orang\nJam Buka: ${widget.room.openingHour} - ${widget.room.closingHour}',
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Organisasi / Komunitas
              TextFormField(
                controller: _organizationController,
                decoration: const InputDecoration(
                  labelText: 'Organisasi / Fakultas / Kelas',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Keperluan / Purpose
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Tujuan Pemakaian',
                  prefixIcon: Icon(Icons.event_note),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Jumlah Peserta
              TextFormField(
                controller: _participantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Peserta',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  final num = int.tryParse(val);
                  if (num == null || num <= 0) return 'Masukkan angka valid';
                  if (num > widget.room.capacity) {
                    return 'Melebihi kapasitas (${widget.room.capacity} orang)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Pilihan Tanggal
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: Colors.blue),
                title: const Text('Tanggal Penggunaan'),
                subtitle: Text(dateFormat.format(_selectedDate)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: const Text('Ubah'),
                ),
              ),
              const Divider(),

              // Pilihan Waktu Mulai & Selesai
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mulai', style: TextStyle(fontSize: 13)),
                      subtitle: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.access_time, size: 20),
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: _startTime);
                          if (picked != null) setState(() => _startTime = picked);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Selesai', style: TextStyle(fontSize: 13)),
                      subtitle: Text(_endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.access_time, size: 20),
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: _endTime);
                          if (picked != null) setState(() => _endTime = picked);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Catatan Tambahan
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Ajukan Booking ke Edge Function', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
