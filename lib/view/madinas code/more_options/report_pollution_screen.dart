import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

// 3. REPORT POLLUTION / ATTACH IMAGE / REPORT DROP DOWN
class ReportPollutionScreen extends StatefulWidget {
  const ReportPollutionScreen({super.key});

  @override
  State<ReportPollutionScreen> createState() => _ReportPollutionScreenState();
}

class _ReportPollutionScreenState extends State<ReportPollutionScreen> {
  String? _selectedIssue;
  final List<String> issues = [
    'Smoke/Fire',
    'Dust Storm',
    'Industrial Emission',
    'Traffic Congestion',
    'Other',
  ];
  bool _imageAttached = false;

  void _handleReportSubmission() {
    // Mock submission logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Report Submitted',
          style: TextStyle(color: kAccentGreen),
        ),
        content: const Text(
          'Thank you for reporting. Your submission will be reviewed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: kAccentGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        title: const Text(
          'Report Pollution',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us keep the air clean by reporting pollution events.',
              style: kTextTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // Report Drop Down
            Text('Type of Pollution', style: kTextTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccentGreen.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssue,
                  hint: Text(
                    'Select an issue...',
                    style: kTextTheme.bodyMedium,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: kAccentGreen),
                  isExpanded: true,
                  style: kTextTheme.bodyMedium,
                  dropdownColor: kCardColor,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIssue = newValue;
                    });
                  },
                  items: issues.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Input
            Text('Details / Description', style: kTextTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the source, time, and severity...',
                hintStyle: kTextTheme.bodyMedium,
                filled: true,
                fillColor: kCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Attach Image
            Text('Attach Image (Optional)', style: kTextTheme.labelLarge),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _imageAttached = !_imageAttached; // Mock image attachment
                });
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageAttached ? kAccentGreen : Colors.white30,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _imageAttached
                            ? Icons.check_circle_outline
                            : Icons.camera_alt,
                        color: _imageAttached ? kAccentGreen : Colors.white30,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _imageAttached
                            ? 'Image Attached'
                            : 'Tap to select/capture image',
                        style: kTextTheme.bodyMedium?.copyWith(
                          color: _imageAttached ? kAccentGreen : Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            ElevatedButton(
              onPressed: _handleReportSubmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Report',
                style: kTextTheme.labelLarge?.copyWith(color: kPrimaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
