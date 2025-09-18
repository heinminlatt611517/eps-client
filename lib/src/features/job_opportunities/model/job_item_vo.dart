class JobItemVO {
  final String title;
  final String city;
  final String type;
  final int postedDaysAgo;

  const JobItemVO({
    required this.title,
    required this.city,
    required this.type,
    required this.postedDaysAgo,
  });
}