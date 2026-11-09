import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';

class CreatePostPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const CreatePostPage({super.key, required this.user});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = "ANNOUNCEMENT";
  bool _publishing = false;

  final List<String> _categories = [
    "ANNOUNCEMENT",
    "ACHIEVEMENTS",
    "EXTERNAL OPPORTUNITY",
    "UPCOMING MEETING",
  ];

  Future<void> _publishPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please enter post description",
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() => _publishing = true);

    try {
      await Supabase.instance.client.from('posts').insert({
        'category': _selectedCategory,
        'description': text,
        'user_id': widget.user['id'],
      });

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: "Post Published Successfully",
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "NEW POST",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              isGlass: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SELECT CATEGORY",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.borderSubtle,
                        ),
                      ),
                    ),
                    items: _categories.map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    "POST DESCRIPTION",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _textController,
                    maxLines: 6,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Write something insightful...",
                      hintStyle: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    text: "PUBLISH POST",
                    width: double.infinity,
                    isLoading: _publishing,
                    icon: Icons.send_rounded,
                    onPressed: _publishing ? null : _publishPost,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
