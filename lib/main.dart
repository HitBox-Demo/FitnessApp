import 'package:flutter/material.dart';
// import 'package:async/async.dart'; // Unused import, commented out for cleanliness
// import 'dart:math';

// 1. THEME & SHARED WIDGETS

void main() => runApp(const FitHeroApp());

/// Centralized color palette for the application
class AppColors {
  static const Color background = Color(0xFF050B18); // Main dark background
  static const Color cardBg = Color(0xFF15182B);     // Lighter card background
  static const Color primary = Color(0xFFFF4500);    // Main orange accent
  static const Color green = Color(0xFF00C853);      // Success/Active green
}

/// Root Application Widget
/// Sets up the MaterialApp, Theme, and Home Screen.
class FitHeroApp extends StatelessWidget {
  const FitHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSiswa',
      debugShowCheckedModeBanner: false,
      // Global Theme Configuration
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary, 
          surface: AppColors.cardBg
        ),
        // Standardized Text Styles
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        // Standardized Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252840),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          hintStyle: const TextStyle(color: Colors.white24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

/// A reusable container with consistent border radius and colors.
/// Used for almost all "boxes" in the app.
class HeroCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const HeroCard({super.key, required this.child, this.color, this.borderColor, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.white10),
      ),
      child: child,
    );
  }
}

/// A specialized card for displaying statistics (Label + Value + Optional Icon)
class HeroStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const HeroStatBox(this.label, this.value, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            // Icon color alternates based on label length for visual variety
            Icon(icon, color: label.length % 2 == 0 ? Colors.green : Colors.orange, size: 16), 
            const SizedBox(height: 5),
          ],
          Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// A consolidated input widget that handles:
/// 1. Standard number input
/// 2. Number input WITH a dropdown unit selector (if dropdownItems is provided)
class HeroInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;
  final bool isText; // UPdate = Allow text input in goals title.

  const HeroInput({
    super.key, 
    required this.label, 
    required this.controller, 
    this.dropdownValue, 
    this.dropdownItems, 
    this.onDropdownChanged,
    this.isText = false, 
  });

  @override
  Widget build(BuildContext context) {
    final hasDropdown = dropdownItems != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 5),
        Row(
          children: [
            // Text Input Field
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                // Switch between Text and Number keyboard based on isText flag
                keyboardType: isText ? TextInputType.text : TextInputType.number,
                textAlign: isText ? TextAlign.start : TextAlign.center, // Align text to start for titles, center for numbers
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    // Adjust corners if attached to dropdown
                    borderRadius: hasDropdown 
                      ? const BorderRadius.horizontal(left: Radius.circular(10)) 
                      : BorderRadius.circular(10),
                    borderSide: BorderSide.none
                  ),
                ),
              ),
            ),
            // Optional Dropdown
            if (hasDropdown)
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                  ),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      dropdownColor: const Color(0xFF252840),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                      onChanged: onDropdownChanged,
                      items: dropdownItems!.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    ),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

// 2. DATA MODELS & BUSINESS LOGIC

class Workout {
  final String title, status;
  final DateTime date;
  final int durationMinutes, exerciseCount;
  final List<Map<String, dynamic>> exercises;
  
  Workout({
    required this.title, 
    required this.date, 
    required this.durationMinutes, 
    required this.exerciseCount, 
    this.exercises = const [], 
    required this.status
  });
}

class Goal {
  final String title, unit;
  final double target;
  double current;
  final DateTime deadline;
  bool isCompleted;
  
  Goal({
    required this.title, 
    required this.target, 
    required this.unit, 
    required this.deadline, 
    this.current = 0, 
    this.isCompleted = false
  });
}

class Achievement {
  final String title, description;
  final int currentProgress, targetProgress;
  final bool isUnlocked;
  final IconData icon;
  
  Achievement({
    required this.title, 
    required this.description, 
    required this.currentProgress, 
    required this.targetProgress, 
    required this.isUnlocked, 
    required this.icon
  });
}

/// Singleton Class to manage App State (Mock Database)
class DataStore {
  static final DataStore _inst = DataStore._internal();
  factory DataStore() => _inst;
  DataStore._internal() { _initMockData(); }

  List<Workout> history = [];
  List<Goal> goals = [];
  List<Achievement> achievements = [];
  int currentStreak = 3, longestStreak = 364;

  /// Initialize dummy data for display
  /// Running", "Cycling", "Squats", "Deadlift", "Bench Press", "Pull-ups", "Plank", "Lunges", "Push-ups
  void _initMockData() {
    history.addAll([
      Workout(title: "Squats, Bench Press, Push-ups", date: DateTime(2023, 10, 24, 18, 30), durationMinutes: 45, exerciseCount: 3, status: "Completed"),
      Workout(title: "Cycling", date: DateTime.now().subtract(const Duration(days: 3)), durationMinutes: 30, exerciseCount: 1, status: "Completed"),
      Workout(title: "Running", date: DateTime.now(), durationMinutes: 10, exerciseCount: 1, status: "Ongoing"),
    ]);
    
    goals.add(Goal(title: "Run", target: 3, unit: "\t\t\t km/kg", deadline: DateTime.now().add(const Duration(days: 30))));
    
    achievements = [
      Achievement(title: "congrate, you touch grass", description: "Complete your first workout", currentProgress: 22, targetProgress: 1, isUnlocked: true, icon: Icons.track_changes),
      Achievement(title: "Getting Ready", description: "Complete 5 workouts", currentProgress: 22, targetProgress: 5, isUnlocked: true, icon: Icons.track_changes),
      Achievement(title: "Committed Person", description: "Complete 10 workouts", currentProgress: 22, targetProgress: 10, isUnlocked: true, icon: Icons.track_changes),
      Achievement(title: "Dedicated, sir?", description: "Complete 25 workouts", currentProgress: 22, targetProgress: 25, isUnlocked: false, icon: Icons.lock),
      Achievement(title: "Fit Hero!!", description: "Complete 50 workouts", currentProgress: 22, targetProgress: 50, isUnlocked: false, icon: Icons.track_changes),
      Achievement(title: "The Man, The Legend", description: "Complete 100 workouts", currentProgress: 22, targetProgress: 100, isUnlocked: false, icon: Icons.lock),
      Achievement(title: "On Firee~", description: "Maintaining a 3-day Streak", currentProgress: 3, targetProgress: 3, isUnlocked: true, icon: Icons.track_changes),
      Achievement(title: "Weeker", description: "Maintaining a 7-day Streak", currentProgress: 3, targetProgress: 7, isUnlocked: false, icon: Icons.lock),
      Achievement(title: "Monthly Subs", description: "Maintaining a 30-day Streak", currentProgress: 3, targetProgress: 30, isUnlocked: false, icon: Icons.lock),
      Achievement(title: "Achiever, arent we?", description: "Complete 30 goals", currentProgress: 0, targetProgress: 3, isUnlocked: false, icon: Icons.lock),
    ];
  }

  // -- CRUD OPERATIONS --
  void addGoal(Goal g) => goals.add(g);
  void removeGoal(Goal g) => goals.remove(g);
  void addWorkout(Workout w) => history.insert(0, w);
  void removeWorkout(Workout w) => history.remove(w);
  
  // -- LOGIC --
  void updateGoalProgress(Goal g, double change) {
    g.current = (g.current + change).clamp(0, double.infinity);
    g.isCompleted = g.current >= g.target;
  }

  // -- GETTERS (Computed Props) --
  int get totalWorkouts => history.where((w) => w.status == "Completed").length;
  int get workoutsThisWeek => history.where((w) => w.date.isAfter(DateTime.now().subtract(const Duration(days: 7))) && w.status == "Completed").length;
  int get avgDuration => history.isEmpty ? 0 : (history.map((e) => e.durationMinutes).reduce((a, b) => a + b) / history.length).round();
  int get activeGoals => goals.where((g) => !g.isCompleted).length;
  int get completedGoals => goals.where((g) => g.isCompleted).length;
}

// 3. MAIN SCAFFOLD & NAVIGATION

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _idx = 0;
  final _pages = [const HomeScreen(), const GoalsScreen(), const HistoryScreen(), const AwardsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic Page Switching
      body: SafeArea(child: _pages[_idx]),
      
      // The Big Orange "+" Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogWorkoutScreen())).then((_) => setState((){})),
        backgroundColor: const Color.fromARGB(255, 215, 81, 24), // Custom Orange
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0A0E1F),
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, "Home", 0),
            _navItem(Icons.track_changes, "Goals", 1), // GOAL ICON (Bottom Nav)
            const SizedBox(width: 40), // Space for FAB
            _navItem(Icons.history, "History", 2),
            _navItem(Icons.emoji_events, "Awards", 3),
          ],
        ),
      ),
    );
  }

  /// Helper to build navigation items
  Widget _navItem(IconData icon, String label, int i) => InkWell(
    onTap: () => setState(() => _idx = i),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: _idx == i ? AppColors.primary : Colors.grey, size: 26),
      Text(label, style: TextStyle(color: _idx == i ? AppColors.primary : Colors.grey, fontSize: 10))
    ]),
  );
}

// 4. SCREENS

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DataStore();
    final textTheme = Theme.of(context).textTheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.fitness_center, color: Colors.white)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("FitSiswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Stay Consistent, Stay Strong", style: textTheme.bodySmall),
            ]),
          ]),
          
          const SizedBox(height: 20),
          
          // Streak Card
          HeroCard(
            color: Colors.transparent, // Handled by gradient
            padding: EdgeInsets.zero, // Handled by inner container
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF4100)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.local_fire_department, color: Colors.white, size: 20), SizedBox(width: 5), Text("Current Streak")]),
                    const SizedBox(height: 10),
                    Text("${store.currentStreak} Days", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("Longest: ${store.longestStreak} days", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                  const Icon(Icons.local_fire_department, size: 60, color: Colors.white30),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Weekly Progress Chart (Mock)
          HeroCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.bar_chart, color: AppColors.primary), SizedBox(width: 8), Text("Weekly Progress", style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) => Column(children: [
                Container(width: 12, height: [20.0, 40.0, 10.0, 30.0, 60.0, 100.0, 50.0][i], decoration: BoxDecoration(color: i==5 ? AppColors.primary : Colors.blueGrey, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Text(["M","T","W","T","F","S","S"][i], style: textTheme.bodySmall),
              ])),
            ),
            const Divider(color: Colors.white10, height: 30),
            Text("22 workouts completed this week", style: textTheme.bodySmall),
          ])),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(children: [
            Expanded(child: HeroStatBox("Total Workouts", "${store.totalWorkouts}", icon: Icons.trending_up)),
            const SizedBox(width: 15),
            Expanded(child: HeroStatBox("This Week", "${store.workoutsThisWeek}", icon: Icons.local_fire_department)),
          ]),
          
          const SizedBox(height: 20),
          
          // "Start Workout" Shortcut
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogWorkoutScreen())),
            child: const Text("Start Workout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }
}

// --- GOALS SCREEN ---
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = DataStore();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Goals", style: Theme.of(context).textTheme.headlineSmall),
          Text("Set targets and track progress", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          // Summary Stats
          Row(children: [
            Expanded(child: HeroStatBox("Active Goals", "${store.activeGoals}")),
            const SizedBox(width: 15),
            Expanded(child: HeroStatBox("Completed", "${store.completedGoals}")),
          ]),
          const SizedBox(height: 20),
          
          // Empty State
          if (store.goals.isEmpty)
             const HeroCard(child: Center(child: Column(children: [Icon(Icons.show_chart, size: 48, color: Colors.grey), Text("No goals yet")]))),
          
          // List of Goals
          ...store.goals.map((g) => HeroCard(
            margin: const EdgeInsets.only(bottom: 15),
            borderColor: g.isCompleted ? Colors.green: null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8), 
                    decoration: BoxDecoration(color: (g.isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)), 
                    child: Icon(Icons.track_changes, color: g.isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2), size: 20) // GOAL ICON (Goal Card)
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.title, style: Theme.of(context).textTheme.titleMedium),
                    Text("${g.current.toInt()} / ${g.target.toInt()} ${g.unit}", style: Theme.of(context).textTheme.bodySmall),
                  ])
                ]),
                // Remove Goal Button
                InkWell(onTap: () => setState(() {
                  // Complete Goal -> Record as Workout
                  DataStore().addWorkout(Workout(title: "Goal Reached: ${g.title}", date: DateTime.now(), durationMinutes: 30, exerciseCount: 1, status: "Completed", exercises: [{'name': g.title, 'sets': '1', 'reps': '${g.current.toInt()}', 'quantity': '${g.target}', 'unit': g.unit}]));
                  DataStore().removeGoal(g);
                }), child: const Icon(Icons.close, color: Colors.grey, size: 18))
              ]),
              const SizedBox(height: 15),
              // Progress Bar
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: (g.current/g.target).clamp(0.0, 1.0), minHeight: 6, backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation(g.isCompleted ? Colors.green : AppColors.primary))),
              const SizedBox(height: 15),
              // +/- Controls
              Row(children: [
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), onPressed: () => setState(() => DataStore().updateGoalProgress(g, -1)), child: const Text("-1"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: g.isCompleted ? Colors.green : AppColors.primary, foregroundColor: Colors.white), onPressed: () => setState(() => DataStore().updateGoalProgress(g, 1)), child: const Text("+1"))),
              ])
            ]),
          )),
          
          // Add New Goal Button
          SizedBox(width: double.infinity, height: 50, 
          child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _showAddGoal, 
          icon: const Icon(Icons.add, color: Colors.white), label: const Text("Add New Goal", style: TextStyle(color: Colors.white)))),
        ],
      ),
    );
  }

  // Modal for Adding Goal
  void _showAddGoal() {
    final tc = TextEditingController(), tgc = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.background, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Create New Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        HeroInput(label: "Goal Title", controller: tc, isText: true),
        const SizedBox(height: 15),
        HeroInput(label: "Target", controller: tgc), 
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () {
          if(tc.text.isNotEmpty && tgc.text.isNotEmpty) {
            setState(() => DataStore().addGoal(Goal(title: tc.text, target: double.tryParse(tgc.text)??0, unit: "km", deadline: DateTime.now())));
            Navigator.pop(context);
          }
        }, child: const Text("Create Goal", style: TextStyle(color: Colors.white)))),
        const SizedBox(height: 20),
      ]),
    ));
  }
}

// --- HISTORY SCREEN ---
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final store = DataStore();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Workout History", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: HeroStatBox("Total", "${store.totalWorkouts}")),
            const SizedBox(width: 10),
            Expanded(child: HeroStatBox("Avg Time", "${store.avgDuration}m")),
          ]),
          const SizedBox(height: 20),
          // Render History List
          ...store.history.map((w) {
            bool ongoing = w.status == "Ongoing";
            return HeroCard(
              margin: const EdgeInsets.only(bottom: 12),
              borderColor: ongoing ? Colors.blue : null,
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(w.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text("${w.date.month}/${w.date.day}", style: TextStyle(color: Colors.blue[200], fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                      decoration: BoxDecoration(color: (ongoing?Colors.blue:Colors.green).withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(4)), child: Text(w.status, style: TextStyle(color: ongoing?Colors.blue:Colors.green, 
                      fontSize: 10, fontWeight: FontWeight.bold))),
                    ])
                  ]),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), 
                    borderRadius: BorderRadius.circular(20)), child: Text("${w.exerciseCount} exercises", 
                    style: const TextStyle(color: Colors.orange, fontSize: 10))),
                    const SizedBox(width: 10),
                    InkWell(onTap: () => setState(() => DataStore().removeWorkout(w)), child: const Icon(Icons.close, color: Colors.grey, size: 18))
                  ])
                ]),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// --- AWARDS SCREEN ---
class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = DataStore();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Achievements", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        // Grid View for Achievements
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85),
          itemCount: store.achievements.length,
          itemBuilder: (ctx, i) {
            final a = store.achievements[i];
            return HeroCard(
              borderColor: a.isUnlocked ? Colors.orange : null,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: a.isUnlocked ? Colors.pink : Colors.black26, shape: BoxShape.circle), child: Icon(a.icon, color: a.isUnlocked ? Colors.pinkAccent : Colors.grey, size: 30)),
                const SizedBox(height: 10),
                Text(a.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(a.description, textAlign: TextAlign.center, style: Theme.of(ctx).textTheme.bodySmall),
                const Spacer(),
                if (a.isUnlocked) const Text("Unlocked", style: TextStyle(color: Colors.green, fontSize: 10))
                else LinearProgressIndicator(value: a.currentProgress/a.targetProgress, backgroundColor: Colors.black, valueColor: const AlwaysStoppedAnimation(Colors.blueGrey))
              ]),
            );
          },
        )
      ]),
    );
  }
}

// --- LOG WORKOUT SCREEN ---
class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});
  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _nameC = TextEditingController(), _setsC = TextEditingController(), _repsC = TextEditingController(), _qtyC = TextEditingController(text: " ");
  String _unit = "kg";
  List<Map<String, dynamic>> added = [];
  final _tags = ["Running", "Cycling", "Squats", "Deadlift", "Bench Press", "Pull-ups", "Plank", "Lunges", "Push-ups"]; // Exercises List

  // Add exercise to temporary list
  void _add() {
    if (_nameC.text.isNotEmpty) {
      setState(() => added.add({'name': _nameC.text, 'sets': _setsC.text, 'reps': _repsC.text, 'quantity': _qtyC.text, 'unit': _unit}));
      _clear();
    }
  }

  // Clear input fields
  void _clear() {
    setState(() { _nameC.clear(); _setsC.clear(); _repsC.clear(); _qtyC.text = " "; _unit = "kg"; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Log Workout", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Input Area
          HeroCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Add Exercise", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: _nameC, decoration: const InputDecoration(hintText: "e.g. Bench Press"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            // Quick Tag Chips
            Wrap(spacing: 8, runSpacing: 8, children: _tags.map((e) => InkWell(onTap: () => setState(() => _nameC.text = e), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
            decoration: BoxDecoration(color: const Color(0xFF252840), borderRadius: BorderRadius.circular(8)), child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 12))))).toList()),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: HeroInput(label: "Sets", controller: _setsC)),
              const SizedBox(width: 10),
              Expanded(child: HeroInput(label: "Reps", controller: _repsC)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: HeroInput(label: "Quantity", controller: _qtyC, dropdownValue: _unit, dropdownItems: const ["kg","lbs","km","min"], onDropdownChanged: (v) => setState(() => _unit = v!))),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), onPressed: _add, child: const Text("✓ Add"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), onPressed: _clear, child: const Text("Clear"))),
            ])
          ])),
          const SizedBox(height: 20),
          // List of Added Exercises (Temporary)
          ...added.map((ex) => HeroCard(margin: const EdgeInsets.only(bottom: 10), child: Row(children: [
            const Icon(Icons.fitness_center, color: Colors.orange), const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${ex['sets']} sets • ${ex['reps']} reps • ${ex['quantity']} ${ex['unit']}", style: const TextStyle(color: Colors.grey, fontSize: 12))
            ])),
            InkWell(onTap: () => setState(() => added.remove(ex)), child: const Icon(Icons.close, color: Colors.grey, size: 18))
          ]))),
          // Final Finish Button
          if (added.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 20), child: SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            // Passing DateTime.now() to record the time when the workout is finished
            onPressed: () { DataStore().addWorkout(Workout(title: added.map((e)=>e['name']).join(", "), date: DateTime.now(), durationMinutes: 45, exerciseCount: added.length, exercises: added, status: "Completed")); Navigator.pop(context); },
            child: const Text("✓ Complete Workout", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ))),
        ]),
      ),
    );
  }
}


// -- Does the app save changes? Where does it save them? -- //
// No, the app does not permanently save changes.
// How it works currently: The app uses In-Memory Storage (RAM). The DataStore class is a "Singleton" that holds your goals, 
//history, and achievements in simple lists (List<Workout>, List<Goal>) while the app is running.

// What happens on restart: 
//As soon as you close the app or perform a full restart, all data disappears and resets to the default values defined in _initMockData().


// This is just a simulation. Data exists only while the app is open.
// To make it save permanently, you would need to implement a database solution like SharedPreferences, Hive, or SQLite.