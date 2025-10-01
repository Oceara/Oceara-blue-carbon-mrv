enum LandStatus { pending, approved, rejected }

class LandParcel {
  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String ownerUserId;
  LandStatus status;

  LandParcel({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.ownerUserId,
    this.status = LandStatus.pending,
  });
}


