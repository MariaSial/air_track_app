import 'dart:io';
import 'package:air_track_app/providers/reports_provider.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_dropdown.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:air_track_app/services/report_service.dart';

class ReportPollutionScreen extends ConsumerStatefulWidget {
  const ReportPollutionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPollutionScreen> createState() =>
      _ReportPollutionScreenState();
}

class _ReportPollutionScreenState extends ConsumerState<ReportPollutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final categoriesController = TextEditingController();

  XFile? selectedImage;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    categoriesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (photo != null) {
        // Check file size before setting
        final file = File(photo.path);
        final size = await file.length();

        if (size > 2 * 1024 * 1024) {
          if (mounted) {
            _showSnack(
              'Image size must not exceed 2 MB. Please choose a smaller image.',
            );
          }
          return;
        }

        setState(() => selectedImage = photo);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to pick image: ${e.toString()}');
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove'),
                onTap: () {
                  const String baseUrl =
                      'http://192.168.1.100:8000'; // Replace with your actual IP and port                static const String baseUrl = 'http://192.168.1.100:8000'; // Replace with your actual IP and port
                  Navigator.pop(context);
                  setState(() => selectedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (locationController.text.trim().isEmpty) {
      _showSnack('Please select a city');
      return;
    }
    if (categoriesController.text.trim().isEmpty) {
      _showSnack('Please select a category');
      return;
    }
    if (selectedImage != null) {
      final size = await File(selectedImage!.path).length();
      if (size > 2 * 1024 * 1024) {
        _showSnack('Image size must not exceed 2 MB');
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final response = await ReportService.submitReport(
        title: nameController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        pollutionType: categoriesController.text.trim(),
        photo: selectedImage != null ? File(selectedImage!.path) : null,
      );

      _showSnack(response['message'] ?? 'Report submitted successfully');

      // Clear form
      setState(() {
        nameController.clear();
        descriptionController.clear();
        locationController.clear();
        categoriesController.clear();
        selectedImage = null;
      });

      // Refresh reports provider so it appears immediately
      await ref.read(reportsProvider.notifier).refreshReports();
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              const AqiAppBar(title: "Report Pollution"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: nameController,
                          hintText: "Title",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter title'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: locationController,
                          hintText: "City",
                          suffixIcon: AppDropdown(
                            items: cities,
                            onChanged: (val) =>
                                setState(() => locationController.text = val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: categoriesController,
                          hintText: "Category",
                          suffixIcon: AppDropdown(
                            items: categorieslist,
                            onChanged: (val) =>
                                setState(() => categoriesController.text = val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: descriptionController,
                          hintText: "Description",
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.82,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: _showImageOptions,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                selectedImage == null
                                    ? Text(
                                        'Image Upload',
                                        style: TextStyle(color: grey),
                                      )
                                    : Expanded(
                                        child: Image.file(
                                          File(selectedImage!.path),
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                Icon(Icons.attach_file, color: blue),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Photo size must not exceed 2MB',
                          style: TextStyle(fontSize: 12, color: grey),
                        ),
                        const SizedBox(height: 30),
                        BlueButton(
                          text: isLoading ? "Submitting..." : "Submit",
                          onPressed: isLoading ? null : _submitReport,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
