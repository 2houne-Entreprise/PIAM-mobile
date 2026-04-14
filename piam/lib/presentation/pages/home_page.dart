import 'package:flutter/material.dart';
import 'package:piam/presentation/widgets/home_welcome_widget.dart';
import 'package:piam/presentation/widgets/parametrage_initial_widget.dart';
import 'package:piam/screens/parametrage_initial_screen.dart';
import 'package:piam/presentation/pages/dashboard/dashboard_page.dart';
import '../../services/database_service.dart';

class HomePage extends StatefulWidget {
  final dynamic user;
  final dynamic localite;
  const HomePage({Key? key, required this.user, required this.localite})
    : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _checkedParametrage = false;

  static const List<String> _titles = [
    'Accueil',
    'Paramétrage initial',
    'Dashboard',
  ];

  @override
  void initState() {
    super.initState();
    _checkParametrage();
  }

  Future<void> _checkParametrage() async {
    final param = await DatabaseService().getParametreUtilisateur();
    setState(() {
      _checkedParametrage = true;
      if (param == null) {
        // Rediriger de force vers le paramétrage si rien n'est paramétré
        _selectedIndex = 1;
      } else {
        // Si paramétrage fait, on peut aller sur l'accueil ou le Dashboard (ici on affiche l'accueil par défaut)
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Attendre la vérification du paramétrage avant d'afficher l'UI
    if (!_checkedParametrage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PIAM - Ministère Hydraulique et de l\'assainissement',
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeWelcomeWidget(),
          // Composant fonctionnel du matin
          ParametrageInitialWidget(
            onGoToDashboard: () {
              setState(() {
                _selectedIndex = 2; // Basculer vers Dashboard (index 2)
              });
            },
          ),
          DashboardPage(
            user: widget.user,
            localite: widget.localite,
            onGoToParametrage: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramétrage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
