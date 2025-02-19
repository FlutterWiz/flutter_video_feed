enum RouterEnums {
  signUpView('/sign_up_view'),
  signInView('/sign_in_view'),
  dashboardView('/dashboard_view'),
  searchView('/search_view'),
  profileView('/profile_view');

  final String routeName;

  const RouterEnums(this.routeName);
}
