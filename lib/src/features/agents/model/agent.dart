/// Simple data model
class Agent {
  final String name;
  final double rating;
  final String location;
  final bool canRequest;

  Agent({
    required this.name,
    required this.rating,
    required this.location,
    required this.canRequest,
  });
}