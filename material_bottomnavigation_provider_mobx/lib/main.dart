import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/enums.dart';
import 'constants/keys.dart';
import 'services/preferences_service.dart';
import 'stores/destinations_store.dart';
import 'stores/home_store.dart';
import 'stores/dashboard_store.dart';
import 'stores/notifications_store.dart';
import 'stores/settings_store.dart';
import 'pages/home_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/notifications_page.dart';
import 'pages/settings_page.dart';

void main() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(App(sharedPreferences));
}

class App extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const App(this.sharedPreferences, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DestinationsStore>(
          builder: (_) => DestinationsStore(),
        ),
        Provider<HomeStore>(
          builder: (_) => HomeStore(),
        ),
        Provider<DashboardStore>(
          builder: (_) => DashboardStore(),
        ),
        Provider<NotificationsStore>(
          builder: (_) => NotificationsStore(),
        ),
        Provider<PreferencesService>(
          builder: (_) => PreferencesService(sharedPreferences),
        ),
        ProxyProvider<PreferencesService, SettingsStore>(
          builder: (_, preferencesService, __) =>
              SettingsStore(preferencesService),
        ),
      ],
      child: Consumer<SettingsStore>(
        builder: (context, store, _) {
          return Observer(
            builder: (_) {
              return MaterialApp(
                title: 'App title',
                theme: store.useDarkMode ? ThemeData.dark() : ThemeData.light(),
                home: Consumer<DestinationsStore>(
                  builder: (context, store, _) {
                    return Observer(
                      builder: (_) {
                        return Scaffold(
                          appBar: AppBar(
                            title: AppBarTitle(store.selectedDestination),
                          ),
                          body: SafeArea(
                            child: PageContainer(
                              store.selectedDestination,
                            ),
                          ),
                          bottomNavigationBar: AppBottomNavigationBar(store),
                          floatingActionButton: store.selectedDestination ==
                                  Destination.Settings
                              ? null
                              : FloatingActionButton(
                                  key: Keys.incrementButtonKey,
                                  onPressed: () {
                                    switch (store.selectedDestination) {
                                      case Destination.Home:
                                        Provider.of<HomeStore>(context)
                                            .increment();
                                        break;
                                      case Destination.Dashboard:
                                        Provider.of<DashboardStore>(context)
                                            .increment();
                                        break;
                                      case Destination.Notifications:
                                        Provider.of<NotificationsStore>(context)
                                            .increment();
                                        break;
                                      case Destination.Settings:
                                        break;
                                    }
                                  },
                                  child: Icon(Icons.add),
                                ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  final Destination destination;
  const AppBarTitle(this.destination, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (destination) {
      case Destination.Dashboard:
        return Text('Dashboard', key: Keys.dashboardPageTitleKey);
      case Destination.Notifications:
        return Text('Slideshow', key: Keys.notificationsPageTitleKey);
      case Destination.Settings:
        return Text('Settings', key: Keys.settingsPageTitleKey);
      default:
        return Text('Home', key: Keys.homePageTitleKey);
    }
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  final DestinationsStore store;
  const AppBottomNavigationBar(
    this.store, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: Key('bottomNavigationBar'),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: store.selectedDestinationIndex,
      items: DestinationsStoreBase.destinations.map(
        (option) {
          switch (option) {
            case Destination.Home:
              return BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              );
            case Destination.Dashboard:
              return BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                title: Text('Dashboard'),
              );
            case Destination.Notifications:
              return BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                title: Text('Notifications'),
              );
            case Destination.Settings:
              return BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text('Settings'),
              );
          }
        },
      ).toList(),
      onTap: (index) => store.selectDestination(index),
    );
  }
}

class PageContainer extends StatelessWidget {
  final Destination destination;

  const PageContainer(this.destination, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (destination) {
      case Destination.Dashboard:
        return DashboardPage(key: Keys.dashboardPageKey);
      case Destination.Notifications:
        return NotificationsPage(key: Keys.notificationsPageKey);
      case Destination.Settings:
        return SettingsPage(key: Keys.settingsPageKey);
      default:
        return HomePage(key: Keys.homePageKey);
    }
  }
}
