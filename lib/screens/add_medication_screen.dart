import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication; // For editing existing medication

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedForm = 'Tablet';
  String _selectedFrequency = 'Once daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  List<TimeOfDay> _selectedTimes = [];
  DateTime _startDate = DateTime.now();
  bool _remindersEnabled = true;
  String _durationUnit = 'Days';
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Default: all days

  @override
  void initState() {
    super.initState();

    // If editing, populate fields
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _selectedForm = widget.medication!.form;
      _selectedFrequency = widget.medication!.frequency;
      _startDate = widget.medication!.startDate;
      _remindersEnabled = widget.medication!.remindersEnabled;
      _selectedDays = List.from(widget.medication!.selectedDays);

      // Parse times
      _selectedTimes = widget.medication!.times.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();

      if (widget.medication!.durationDays != null) {
        _durationController.text = widget.medication!.durationDays.toString();
      }
    } else {
      // Default time for new medication
      _selectedTimes = [_selectedTime];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDosageField(),
                      const SizedBox(height: AppSpacing.md),
                      _buildFormSelector(),
                      const SizedBox(height: AppSpacing.md),
                      _buildFrequencySelector(),
                      const SizedBox(height: AppSpacing.md),
                      _buildTimeSelector(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDaySelector(),
                      const SizedBox(height: AppSpacing.md),
                      _buildStartDatePicker(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDurationField(),
                      const SizedBox(height: AppSpacing.md),
                      _buildRemindersCheckbox(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryBlack, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.medication == null ? 'Add Medication' : 'Edit Medication',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return AppInput(
      label: 'Medication Name *',
      placeholder: 'e.g., Aspirin',
      controller: _nameController,
    );
  }

  Widget _buildDosageField() {
    return AppInput(
      label: 'Dosage *',
      placeholder: 'e.g., 100mg',
      controller: _dosageController,
    );
  }

  Widget _buildFormSelector() {
    final forms = ['Tablet', 'Capsule', 'Liquid', 'Injection', 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Form',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: forms.take(3).map((form) {
            final isSelected = _selectedForm == form;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: form != 'Liquid' ? 8 : 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedForm = form;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlack
                          : AppColors.pureWhite,
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        form,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.pureWhite
                              : AppColors.primaryBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = [
      'Once daily',
      'Twice daily',
      'Three times daily',
      'Custom schedule',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...frequencies.map((freq) {
          final isSelected = _selectedFrequency == freq;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFrequency = freq;
                  // Update times based on frequency
                  if (freq == 'Once daily') {
                    _selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];
                  } else if (freq == 'Twice daily') {
                    _selectedTimes = [
                      const TimeOfDay(hour: 9, minute: 0),
                      const TimeOfDay(hour: 21, minute: 0),
                    ];
                  } else if (freq == 'Three times daily') {
                    _selectedTimes = [
                      const TimeOfDay(hour: 9, minute: 0),
                      const TimeOfDay(hour: 14, minute: 0),
                      const TimeOfDay(hour: 21, minute: 0),
                    ];
                  }
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlack
                      : AppColors.pureWhite,
                  border: Border.all(color: AppColors.primaryBlack, width: 1),
                ),
                child: Center(
                  child: Text(
                    freq,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.pureWhite
                          : AppColors.primaryBlack,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ..._selectedTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _selectTime(index),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border.all(color: AppColors.primaryBlack, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTimeOfDay(time),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlack,
              onPrimary: AppColors.pureWhite,
              surface: AppColors.pureWhite,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildDaySelector() {
    final days = [
      {'label': 'M', 'value': 1, 'name': 'Monday'},
      {'label': 'T', 'value': 2, 'name': 'Tuesday'},
      {'label': 'W', 'value': 3, 'name': 'Wednesday'},
      {'label': 'T', 'value': 4, 'name': 'Thursday'},
      {'label': 'F', 'value': 5, 'name': 'Friday'},
      {'label': 'S', 'value': 6, 'name': 'Saturday'},
      {'label': 'S', 'value': 7, 'name': 'Sunday'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Days',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: days.map((day) {
            final isSelected = _selectedDays.contains(day['value'] as int);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: day['value'] != 7 ? 4 : 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Don't allow deselecting all days
                        if (_selectedDays.length > 1) {
                          _selectedDays.remove(day['value'] as int);
                        }
                      } else {
                        _selectedDays.add(day['value'] as int);
                        _selectedDays.sort();
                      }
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlack
                          : AppColors.pureWhite,
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.pureWhite
                              : AppColors.primaryBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _getDaysDescription(),
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    );
  }

  String _getDaysDescription() {
    if (_selectedDays.length == 7) {
      return 'Every day';
    } else if (_selectedDays.length == 5 &&
        _selectedDays.contains(1) &&
        _selectedDays.contains(2) &&
        _selectedDays.contains(3) &&
        _selectedDays.contains(4) &&
        _selectedDays.contains(5)) {
      return 'Weekdays only';
    } else if (_selectedDays.length == 2 &&
        _selectedDays.contains(6) &&
        _selectedDays.contains(7)) {
      return 'Weekends only';
    } else {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final selectedNames = _selectedDays.map((d) => dayNames[d - 1]).toList();
      return selectedNames.join(', ');
    }
  }

  Widget _buildStartDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              border: Border.all(color: AppColors.primaryBlack, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_startDate.month}/${_startDate.day}/${_startDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlack,
              onPrimary: AppColors.pureWhite,
              surface: AppColors.pureWhite,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryBlack,
                ),
                decoration: const InputDecoration(
                  hintText: 'Number',
                  hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: AppColors.primaryBlack,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: AppColors.primaryBlack,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: AppColors.primaryBlack,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border.all(color: AppColors.primaryBlack, width: 1),
              ),
              child: DropdownButton<String>(
                value: _durationUnit,
                underline: const SizedBox(),
                items: ['Days', 'Weeks', 'Months'].map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _durationUnit = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRemindersCheckbox() {
    return InkWell(
      onTap: () {
        setState(() {
          _remindersEnabled = !_remindersEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: Border.all(color: AppColors.primaryBlack, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _remindersEnabled
                    ? AppColors.primaryBlack
                    : AppColors.pureWhite,
                border: Border.all(color: AppColors.primaryBlack, width: 1),
              ),
              child: _remindersEnabled
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.pureWhite,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Enable reminders',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        AppButton(
          text: widget.medication == null
              ? 'Save Medication'
              : 'Update Medication',
          variant: ButtonVariant.primary,
          fullWidth: true,
          onPressed: _saveMedication,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: 'Cancel',
          variant: ButtonVariant.ghost,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
        if (widget.medication != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            text: 'Delete Medication',
            variant: ButtonVariant.secondary,
            fullWidth: true,
            onPressed: _deleteMedication,
          ),
        ],
      ],
    );
  }

  void _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.primaryBlack,
        ),
      );
      return;
    }

    // Convert duration to days
    int? durationDays;
    if (_durationController.text.isNotEmpty) {
      final duration = int.tryParse(_durationController.text);
      if (duration != null) {
        if (_durationUnit == 'Weeks') {
          durationDays = duration * 7;
        } else if (_durationUnit == 'Months') {
          durationDays = duration * 30;
        } else {
          durationDays = duration;
        }
      }
    }

    // Convert times to string format (HH:mm)
    final times = _selectedTimes.map((time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }).toList();

    final medication = Medication(
      id:
          widget.medication?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      dosage: _dosageController.text,
      form: _selectedForm,
      frequency: _selectedFrequency,
      times: times,
      startDate: _startDate,
      durationDays: durationDays,
      remindersEnabled: _remindersEnabled,
      selectedDays: _selectedDays,
    );

    final provider = Provider.of<MedicationProvider>(context, listen: false);

    if (widget.medication == null) {
      await provider.addMedication(medication);
    } else {
      await provider.updateMedication(medication);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteMedication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.primaryBlack, width: 2),
        ),
        title: const Text(
          'Delete Medication',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlack,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this medication? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.gray500),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            text: 'Delete',
            variant: ButtonVariant.primary,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.medication != null) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      await provider.deleteMedication(widget.medication!.id);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
