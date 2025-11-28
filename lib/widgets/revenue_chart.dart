import 'package:flutter/material.dart';

// Simple chart implementation using Flutter's built-in widgets
// For production, consider using fl_chart package for more advanced charts

class RevenueChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final Color primaryColor;
  final double height;

  const RevenueChart({
    super.key,
    required this.data,
    this.title = 'Revenue Chart',
    this.primaryColor = const Color(0xFF006B3C),
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Y-axis labels
                SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatValue(maxValue),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        _formatValue(maxValue * 0.75),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        _formatValue(maxValue * 0.5),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        _formatValue(maxValue * 0.25),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Chart area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((item) => _buildBar(item, maxValue)).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-axis labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.map((item) => 
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(ChartData item, double maxValue) {
    final heightRatio = maxValue > 0 ? item.value / maxValue : 0;
    final barHeight = (height - 80) * heightRatio; // Adjust for padding and labels

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value label on top of bar
            if (barHeight > 20)
              Text(
                _formatValue(item.value),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            // Bar
            Container(
              width: double.infinity,
              height: barHeight.clamp(2.0, double.infinity),
              decoration: BoxDecoration(
                color: item.color ?? primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    (item.color ?? primaryColor).withValues(alpha: 0.8),
                    item.color ?? primaryColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class LineChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final Color lineColor;
  final double height;

  const LineChart({
    super.key,
    required this.data,
    this.title = 'Line Chart',
    this.lineColor = const Color(0xFF006B3C),
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.length < 2) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Insufficient data for line chart',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: LineChartPainter(
                data: data,
                maxValue: maxValue,
                minValue: minValue,
                lineColor: lineColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((item) => 
              Text(
                item.label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;
  final double minValue;
  final Color lineColor;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final normalizedValue = (data[i].value - minValue) / (maxValue - minValue);
      final y = size.height - (size.height * normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final double size;

  const PieChart({
    super.key,
    required this.data,
    this.title = 'Pie Chart',
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: PieChartPainter(data: data, total: total),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((item) => _buildLegendItem(item, total)).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(ChartData item, double total) {
    final percentage = total > 0 ? (item.value / total * 100).toStringAsFixed(1) : '0';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.color ?? Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.label} ($percentage%)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double total;

  PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = data[i].color ?? _getDefaultColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getDefaultColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

// Sample data generators for testing
class ChartDataGenerator {
  static List<ChartData> monthlyRevenue() {
    return [
      ChartData(label: 'Jan', value: 15000, color: const Color(0xFF006B3C)),
      ChartData(label: 'Feb', value: 18500, color: const Color(0xFF2E7D32)),
      ChartData(label: 'Mar', value: 22000, color: const Color(0xFF4CAF50)),
      ChartData(label: 'Apr', value: 19500, color: const Color(0xFF66BB6A)),
      ChartData(label: 'May', value: 25000, color: const Color(0xFF81C784)),
      ChartData(label: 'Jun', value: 28500, color: const Color(0xFF006B3C)),
    ];
  }

  /// Generate profit data (revenue - expenses)
  static List<ChartData> monthlyProfit() {
    // Realistic HomeLinkGH data: Revenue minus total operational expenses
    const double monthlyExpenses = 32415.0; // From expense model
    
    final revenueData = monthlyRevenue();
    return revenueData.map((data) {
      final profit = data.value - monthlyExpenses;
      return ChartData(
        label: data.label,
        value: profit,
        color: profit > 0 ? const Color(0xFF4CAF50) : const Color(0xFFE53E3E),
      );
    }).toList();
  }

  /// Generate expense breakdown data
  static List<ChartData> monthlyExpenseBreakdown() {
    return [
      ChartData(label: 'Salaries', value: 13520, color: const Color(0xFF006B3C)),
      ChartData(label: 'Marketing', value: 4900, color: const Color(0xFF2196F3)),
      ChartData(label: 'Office Rent', value: 3700, color: const Color(0xFFFF9800)),
      ChartData(label: 'Technology', value: 2700, color: const Color(0xFF9C27B0)),
      ChartData(label: 'Transport', value: 2250, color: const Color(0xFFF44336)),
      ChartData(label: 'Utilities', value: 2500, color: const Color(0xFF4CAF50)),
      ChartData(label: 'Insurance', value: 1550, color: const Color(0xFFE91E63)),
      ChartData(label: 'Operations', value: 2400, color: const Color(0xFF795548)),
      ChartData(label: 'Regulatory', value: 1550, color: const Color(0xFF607D8B)),
    ];
  }

  /// Generate revenue vs expenses comparison
  static List<ChartData> revenueVsExpenses() {
    return [
      ChartData(label: 'Revenue', value: 45678, color: const Color(0xFF4CAF50)),
      ChartData(label: 'Expenses', value: 32415, color: const Color(0xFFE53E3E)),
      ChartData(label: 'Net Profit', value: 13263, color: const Color(0xFF006B3C)),
    ];
  }

  static List<ChartData> serviceCategories() {
    return [
      ChartData(label: 'House Cleaning', value: 45, color: Colors.blue),
      ChartData(label: 'Plumbing', value: 28, color: Colors.green),
      ChartData(label: 'Electrical', value: 20, color: Colors.orange),
      ChartData(label: 'Beauty Services', value: 22, color: Colors.pink),
      ChartData(label: 'Transportation', value: 18, color: Colors.purple),
    ];
  }

  static List<ChartData> weeklyBookings() {
    return [
      ChartData(label: 'Mon', value: 45),
      ChartData(label: 'Tue', value: 52),
      ChartData(label: 'Wed', value: 38),
      ChartData(label: 'Thu', value: 61),
      ChartData(label: 'Fri', value: 68),
      ChartData(label: 'Sat', value: 75),
      ChartData(label: 'Sun', value: 42),
    ];
  }
}