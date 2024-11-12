
import 'package:flutter/material.dart';
import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';
import 'package:travel_on_final/features/map/presentation/screens/place_search_screen.dart';

class RouteEditor extends StatefulWidget {
  final List<TravelPoint> points;
  final Function(List<TravelPoint>) onPointsChanged;

  const RouteEditor({
    Key? key,
    required this.points,
    required this.onPointsChanged,
  }) : super(key: key);

  @override
  State<RouteEditor> createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  Future<void> _addPoint(PointType type) async {
    final result = await Navigator.push<TravelPoint>(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(selectedPoints: [],),
      ),
    );

    if (result != null) {
      setState(() {
        widget.points.add(result.copyWith(
          order: widget.points.length,
        ));
        widget.onPointsChanged(widget.points);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.hotel),
              label: const Text('호텔'),
              onPressed: () => _addPoint(PointType.hotel),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant),
              label: const Text('음식점'),
              onPressed: () => _addPoint(PointType.restaurant),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('관광지'),
              onPressed: () => _addPoint(PointType.attraction),
            ),
          ],
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: widget.points.length,
          itemBuilder: (context, index) {
            final point = widget.points[index];
            return ListTile(
              key: Key(point.id),
              leading: Icon(
                point.type == PointType.hotel ? Icons.hotel :
                point.type == PointType.restaurant ? Icons.restaurant :
                Icons.photo_camera,
              ),
              title: Text(point.name),
              subtitle: Text(point.address),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    widget.points.removeAt(index);
                    widget.onPointsChanged(widget.points);
                  });
                },
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = widget.points.removeAt(oldIndex);
              widget.points.insert(newIndex, item);

              // 순서 업데이트
              for (var i = 0; i < widget.points.length; i++) {
                widget.points[i] = widget.points[i].copyWith(order: i);
              }

              widget.onPointsChanged(widget.points);
            });
          },
        ),
      ],
    );
  }
}