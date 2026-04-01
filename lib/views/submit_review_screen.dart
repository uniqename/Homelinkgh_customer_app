import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/booking.dart';
import '../models/provider.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';

/// Submit Review Screen
/// Allows customers to rate providers after booking completion
class SubmitReviewScreen extends StatefulWidget {
  final Booking booking;
  final Provider provider;

  const SubmitReviewScreen({
    super.key,
    required this.booking,
    required this.provider,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewTextController = TextEditingController();
  final _reviewService = ReviewService();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();

  double _overallRating = 5.0;
  double _professionalismRating = 5.0;
  double _punctualityRating = 5.0;
  double _qualityRating = 5.0;
  double _communicationRating = 5.0;

  List<File> _selectedPhotos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedPhotos.length >= 5) {
      _showSnackBar('Maximum 5 photos allowed', isError: true);
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedPhotos.length >= 5) {
      _showSnackBar('Maximum 5 photos allowed', isError: true);
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e', isError: true);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_reviewTextController.text.trim().length < 10) {
      _showSnackBar('Please write at least 10 characters', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create review ID
      final reviewId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload photos if any
      List<String> photoUrls = [];
      if (_selectedPhotos.isNotEmpty) {
        photoUrls = await _reviewService.uploadReviewPhotos(reviewId, _selectedPhotos);
      }

      // Create review object
      final review = Review(
        id: reviewId,
        bookingId: widget.booking.id!,
        customerId: widget.booking.customerId,
        customerName: currentUser.displayName ?? currentUser.email,
        providerId: widget.booking.providerId,
        rating: _overallRating,
        reviewText: _reviewTextController.text.trim(),
        jobTitle: widget.booking.serviceType,
        createdAt: DateTime.now(),
        isVerifiedCustomer: true,
        jobAmount: widget.booking.price,
        photoUrls: photoUrls,
        categoryRatings: {
          'professionalism': _professionalismRating,
          'punctuality': _punctualityRating,
          'quality': _qualityRating,
          'communication': _communicationRating,
        },
      );

      // Submit review
      await _reviewService.submitReview(review);

      // Update booking as rated
      // This would be done via FirebaseService in production

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBar('Error submitting review: $e', isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Review Submitted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for your feedback!'),
            SizedBox(height: 8),
            Text(
              'Your review helps others make informed decisions and helps us maintain quality service.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close review screen
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Your Experience'),
        elevation: 0,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting your review...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(widget.provider.profileImageUrl),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.provider.name,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.booking.serviceType,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'GH₵${widget.booking.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Color(0xFF00A651),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Overall Rating
                    Text(
                      'Overall Rating',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildStarRating(_overallRating, (rating) {
                      setState(() => _overallRating = rating);
                    }),

                    SizedBox(height: 24),

                    // Category Ratings
                    Text(
                      'Rate Specific Aspects',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    _buildCategorySlider(
                      'Professionalism',
                      _professionalismRating,
                      (value) => setState(() => _professionalismRating = value),
                      Icons.person,
                    ),
                    _buildCategorySlider(
                      'Punctuality',
                      _punctualityRating,
                      (value) => setState(() => _punctualityRating = value),
                      Icons.access_time,
                    ),
                    _buildCategorySlider(
                      'Quality',
                      _qualityRating,
                      (value) => setState(() => _qualityRating = value),
                      Icons.star,
                    ),
                    _buildCategorySlider(
                      'Communication',
                      _communicationRating,
                      (value) => setState(() => _communicationRating = value),
                      Icons.chat,
                    ),

                    SizedBox(height: 24),

                    // Review Text
                    Text(
                      'Write Your Review',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _reviewTextController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Share your experience with ${widget.provider.name}...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please write a review';
                        }
                        if (value.trim().length < 10) {
                          return 'Review must be at least 10 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 24),

                    // Photo Upload Section
                    Text(
                      'Add Photos (Optional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Help others by showing your experience (max 5 photos)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 12),

                    // Photo Grid
                    if (_selectedPhotos.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _selectedPhotos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedPhotos[index],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    SizedBox(height: 12),

                    // Photo Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.photo_library),
                            label: Text('Gallery'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePhoto,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Camera'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00A651),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStarRating(double rating, Function(double) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onChanged((index + 1).toDouble()),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Color(0xFFFFD700),
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategorySlider(
    String label,
    double value,
    Function(double) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Color(0xFF00A651)),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text(
                '${value.toStringAsFixed(1)} ⭐',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            activeColor: Color(0xFF00A651),
            inactiveColor: Colors.grey[300],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
