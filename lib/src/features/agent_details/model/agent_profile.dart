/// ======= simple model (all nullable) =======
class AgentProfile {
  final String? name;
  final double? rating;
  final String? location;
  final List<String>? languages;
  final int? experienceYears;
  final List<String>? services;

  const AgentProfile({
    this.name,
    this.rating,
    this.location,
    this.languages,
    this.experienceYears,
    this.services,
  });
}