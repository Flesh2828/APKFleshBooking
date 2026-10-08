import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../models/room_model.dart';
import '../services/supabase_service.dart';

class BookingFormScreen extends StatefulWidget {
  final RoomModel? preselectedRoom;
  final DateTime? initialDate;
  final String? initialStartHour;
  final String? initialEndHour;

  const BookingFormScreen({
    super.key,
    this.preselectedRoom,
    this.initialDate,
    this.initialStartHour,
    this.initialEndHour,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Identitas Pemesan
  late TextEditingController _nameController;
  late TextEditingController _organizationController;

  // 2. Ruangan & Waktu
  List<RoomModel> _rooms = [];
  String? _selectedRoomId;
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  // 3. Rincian Kegiatan
  final _purposeController = TextEditingController();
  final _participantCountController = TextEditingController(text: '30');
  final _additionalFacilitiesController = TextEditingController();
  final _notesController = TextEditingController();

  // 4. Lampiran Dokumen (file_picker)
  PlatformFile? _pickedFile;

  bool _isLoadingRooms = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.currentUser;
    _nameController = TextEditingController(text: user.name);
    _organizationController = TextEditingController(
      text: user.department ?? 'Badan Eksekutif Mahasiswa (BEM)',
    );

    _selectedDate = widget.initialDate ?? DateTime.now();

    if (widget.initialStartHour != null) {
      final parts = widget.initialStartHour!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.initialEndHour != null) {
      final parts = widget.initialEndHour!.split(':');
      if (parts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 12,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    _fetchRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _purposeController.dispose();
    _participantCountController.dispose();
    _additionalFacilitiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    final list = await SupabaseService.getRooms();
    if (mounted) {
      setState(() {
        _rooms = list;
        if (widget.preselectedRoom != null) {
          _selectedRoomId = widget.preselectedRoom!.id;
        } else if (list.isNotEmpty) {
          _selectedRoomId = list.first.id;
        }
        _isLoadingRooms = false;
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lampiran terpilih: ${_pickedFile!.name}'),
              backgroundColor: AppColors.statusAvailable,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih ruangan terlebih dahulu'),
          backgroundColor: AppColors.statusPending,
        ),
      );
      return;
    }

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

    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus lebih akhir dari jam mulai'),
          backgroundColor: AppColors.statusPending,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload dokumen jika ada
      String? attachmentUrl;
      if (_pickedFile != null && _pickedFile!.bytes != null) {
        attachmentUrl = await SupabaseService.uploadBookingDocument(
          fileName: _pickedFile!.name,
          fileBytes: _pickedFile!.bytes!,
        );
      }

      // 2. Buat reservasi
      final count = int.tryParse(_participantCountController.text.trim()) ?? 10;
      final newRes = await SupabaseService.createReservation(
        roomId: _selectedRoomId!,
        startTime: startDateTime,
        endTime: endDateTime,
        purpose: _purposeController.text.trim(),
        organization: _organizationController.text.trim(),
        participantCount: count,
        additionalFacilities:
            _additionalFacilitiesController.text.trim().isNotEmpty
                ? _additionalFacilitiesController.text.trim()
                : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        attachmentFileName: attachmentUrl ?? _pickedFile?.name,
      );

      if (!mounted) return;

      // Show Success Dialog
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.statusAvailable,
            size: 54,
          ),
          title: const Text(
            'Pengajuan Berhasil!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kode Reservasi: ${newRes.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pengajuan Anda telah tercatat dengan status MENUNGGU (PENDING). Admin kampus akan segera meninjau permohonan ini.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Buka Reservasi Saya'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat reservasi: ${e.toString()}'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Formulir Reservasi Ruangan'),
      ),
      body: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  // SECTION 1: Identitas Pemesan
                  _buildSectionCard(
                    stepNumber: '1',
                    title: 'Identitas Pemesan',
                    subtitle: 'Data diri penanggung jawab kegiatan',
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Pemesan *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _organizationController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Unit / Lembaga / Ormawa *',
                          prefixIcon: Icon(Icons.corporate_fare_outlined),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Organisasi wajib diisi'
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // SECTION 2: Ruangan & Waktu Penggunaan
                  _buildSectionCard(
                    stepNumber: '2',
                    title: 'Ruangan & Waktu Penggunaan',
                    subtitle: 'Pilih fasilitas dan jadwal pemakaian',
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRoomId,
                        dropdownColor: AppColors.surfaceVariant,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Ruangan Fasilitas *',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                        items: _rooms.map((r) {
                          return DropdownMenuItem<String>(
                            value: r.id,
                            child: Text(
                              '${r.name} (Kap: ${r.capacity})',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRoomId = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tanggal Pemakaian
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 18, color: AppColors.textMuted),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormatterIndo.formatFull(_selectedDate),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Jam Mulai & Selesai
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickTime(isStart: true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jam Mulai',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')} WIB',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickTime(isStart: false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jam Selesai',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')} WIB',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // SECTION 3: Rincian Kegiatan & Kapasitas
                  _buildSectionCard(
                    stepNumber: '3',
                    title: 'Rincian Kegiatan & Fasilitas',
                    subtitle: 'Detail agenda dan kebutuhan pendukung',
                    children: [
                      TextFormField(
                        controller: _purposeController,
                        maxLines: 2,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Tujuan & Nama Kegiatan *',
                          hintText: 'Misal: Seminar Nasional AI & Data Science 2026',
                          prefixIcon: Icon(Icons.event_note_outlined),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Tujuan kegiatan wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _participantCountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Estimasi Jumlah Peserta *',
                          prefixIcon: Icon(Icons.groups_outlined),
                          suffixText: 'Orang',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                          if (int.tryParse(v) == null) return 'Harus angka valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _additionalFacilitiesController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Kebutuhan Tambahan (Opsional)',
                          hintText: 'Misal: 2 Mic Wireless, Meja Registrasi, dsb',
                          prefixIcon: Icon(Icons.playlist_add_check_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Catatan Khusus Pengelola (Opsional)',
                          hintText: 'Instruksi gladi bersih / teknis lainnya',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // SECTION 4: Lampiran Dokumen (file_picker)
                  _buildSectionCard(
                    stepNumber: '4',
                    title: 'Lampiran Dokumen Izin',
                    subtitle: 'Upload surat permohonan / proposal kegiatan',
                    children: [
                      if (_pickedFile == null)
                        InkWell(
                          onTap: _pickAttachment,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 22, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primaryLight.withValues(alpha: 0.4),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 36,
                                  color: AppColors.primaryLight,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pilih Berkas Lampiran (PDF / Gambar)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Surat izin dekanat / proposal UKM (Maks. 5 MB)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.statusAvailable.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.statusAvailableBg.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.statusAvailable,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pickedFile!.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB • Siap Diunggah',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: AppColors.statusRejected, size: 20),
                                onPressed: () {
                                  setState(() => _pickedFile = null);
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Submit CTA
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Pengajuan Reservasi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
