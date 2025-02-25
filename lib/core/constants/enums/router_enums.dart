enum RouterEnums {
  dashboardView('/dashboard_view'),
  videoFeedView('/video_feed_view'),
  profileView('/profile_view');

  final String routeName;

  const RouterEnums(this.routeName);
}
