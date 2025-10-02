import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../environment.dart';
import '../services/auth_service.dart';

class ReviewSubmissionWidget extends StatefulWidget {
  final String agentId;
  final VoidCallback onReviewSubmitted;

  const ReviewSubmissionWidget({
    super.key,
    required this.agentId,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewSubmissionWidget> createState() => _ReviewSubmissionWidgetState();
}

class _ReviewSubmissionWidgetState extends State<ReviewSubmissionWidget> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      setState(() {
        _errorMessage = 'Please select a rating';
      });
      return;
    }

    // Check if user is authenticated
    if (!AuthService.isLoggedIn) {
      setState(() {
        _errorMessage = 'Please log in to submit a review';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}reviews/add'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'reviewedObjectId': widget.agentId,
          'table': 'user', // Since this is for agents
          'comment': _commentController.text.trim(),
          'rating': _selectedRating,
        }),
      );

      if (response.statusCode == 201) {
        // Success
        _commentController.clear();
        setState(() {
          _selectedRating = 0;
          _isSubmitting = false;
        });
        widget.onReviewSubmitted();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        setState(() {
          _errorMessage = 'Session expired. Please log in again.';
          _isSubmitting = false;
        });
      } else if (response.statusCode == 409) {
        // User already reviewed
        setState(() {
          _errorMessage = 'You have already reviewed this agent';
          _isSubmitting = false;
        });
      } else {
        // Other error
        final responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to submit review';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = index + 1;
            });
          },
          child: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.edit, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Star Rating
          Center(
            child: Column(
              children: [
                _buildStarRating(),
                const SizedBox(height: 8),
                Text(
                  _selectedRating == 0 
                    ? 'Tap to rate' 
                    : '${_selectedRating} star${_selectedRating > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Comment Input
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this agent...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Error Message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Submitting...'),
                    ],
                  )
                : const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
