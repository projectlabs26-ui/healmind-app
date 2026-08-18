/// All user-facing strings in English.
/// This makes it easy to add localization later.
library;

class AppStrings {
  // App
  static const String appName = 'HealMind';
  static const String tagline = 'Your daily mental wellness companion';

  // Navigation
  static const String navHome = 'Home';
  static const String navJournal = 'Journal';
  static const String navBreathe = 'Breathe';
  static const String navCBT = 'CBT';
  static const String navProfile = 'Profile';

  // Home
  static const String greetingMorning = 'Good morning';
  static const String greetingAfternoon = 'Good afternoon';
  static const String greetingEvening = 'Good evening';
  static const String howAreYou = 'How are you feeling today?';
  static const String noMoodToday = 'No check-in yet';
  static const String tapToCheckIn = 'Tap to check in';
  static const String streak = 'Day streak';
  static const String todayAffirmation = 'Today\'s Affirmation';

  // Mood
  static const String moodGreat = 'Great';
  static const String moodOkay = 'Okay';
  static const String moodSad = 'Sad';
  static const String moodAngry = 'Angry';
  static const String moodTired = 'Tired';
  static const String moodNoteHint = 'Add a note (optional)...';
  static const String saveMood = 'Save';
  static const String moodSaved = 'Mood saved!';
  static const String alreadyCheckedIn = 'You already checked in today.';

  // Journal
  static const String journalTitle = 'Journal';
  static const String newEntry = 'New Entry';
  static const String editEntry = 'Edit Entry';
  static const String titleHint = 'Title';
  static const String contentHint = 'Write your thoughts...';
  static const String gratitudeTitle = 'Today I\'m grateful for';
  static const String gratitude1 = '1. Something I\'m grateful for...';
  static const String gratitude2 = '2. Something I\'m grateful for...';
  static const String gratitude3 = '3. Something I\'m grateful for...';
  static const String noEntries =
      'No journal entries yet.\nStart writing today!';
  static const String saveEntry = 'Save Entry';
  static const String deleteEntry = 'Delete Entry';
  static const String deleteConfirm = 'Delete this entry?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Affirmations
  static const String affirmations = 'Affirmations';
  static const String noAffirmations = 'No affirmations loaded';
  static const String shareAffirmation = 'Share this affirmation';

  // Mood Chart
  static const String moodChart = 'Mood History';
  static const String weekly = 'Week';
  static const String monthly = 'Month';
  static const String noMoodData =
      'No mood data yet.\nCheck in daily to see your chart!';

  // Settings
  static const String settings = 'Settings';
  static const String reminderSettings = 'Reminder';
  static const String reminderDesc = 'Daily journal reminder';
  static const String reminderTime = 'Reminder time';
  static const String darkMode = 'Dark Mode';
  static const String dataManagement = 'Data Management';
  static const String exportData = 'Export Data';
  static const String deleteAllData = 'Delete All Data';
  static const String deleteAllConfirm =
      'This will permanently delete all your journal entries, mood data, and settings. This cannot be undone.';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String version = 'Version 1.0.0';

  // Breathing
  static const String breathing = 'Breathing';
  static const String startSession = 'Start Session';
  static const String selectPattern = 'Select Pattern';
  static const String selectDuration = 'Duration';
  static const String inhale = 'Breathe In';
  static const String hold = 'Hold';
  static const String exhale = 'Breathe Out';
  static const String sessionComplete = 'Session Complete!';
  static const String sessionCompleteDesc = 'Great job taking time for yourself.';
  static const String cyclesCompleted = 'Cycles completed';
  static const String totalTime = 'Total time';
  static const String done = 'Done';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String endSession = 'End Session';
  static const String confirmEndSession = 'End this breathing session early?';
  static const String panicButton = 'Panic';
  static const String panicButtonDesc = 'Quick 1-min breathing';
  static const String ambientSound = 'Ambient Sound';
  static const String noSound = 'None';
  static const String rain = 'Rain';
  static const String ocean = 'Ocean';
  static const String forest = 'Forest';
  static const String breathingHistory = 'Breathing History';
  static const String noBreathingSessions = 'No breathing sessions yet.\nStart your first session!';
  static const String minAbbr = 'min';
  static const String comingSoon = 'Coming Soon';

  // CBT
  static const String cbt = 'CBT Toolkit';
  static const String cbtComingSoon =
      'Cognitive Behavioral Therapy tools will be available in a future update.';
  static const String thoughtCatcher = 'Thought Catcher';
  static const String catchYourThought = 'What negative thought is bothering you?';
  static const String thoughtHint = 'Write the thought here...';
  static const String identifyDistortions = 'Identify Distortions';
  static const String distortionsPrompt = 'Which cognitive distortions apply? (select all that apply)';
  static const String rateIntensity = 'Rate Intensity';
  static const String intensityPrompt = 'How strongly do you feel this emotion?';
  static const String reframe = 'Reframe';
  static const String reframePrompt = 'Write a balanced, realistic alternative thought:';
  static const String reframeHint = 'What would be a kinder, more balanced way to think about this?';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String saveCBT = 'Save Reflection';
  static const String cbtHistory = 'CBT History';
  static const String noCBTEntries = 'No CBT reflections yet.\nStart reframing your thoughts!';
  static const String cbtTip = 'CBT Tip';
  static const String thoughtLabel = 'Thought';
  static const String reframedLabel = 'Reframed';
  static const String intensity = 'Intensity';
  static const String distortions = 'Distortions';
  static const String step = 'Step';
  static const String of = 'of';
  static const String viewEntry = 'View Entry';

  // Notifications
  static const String reminderTitle = 'Time to journal';
  static const String reminderBody =
      'How was your day? Take a moment to journal your thoughts 🌙';

  // General
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String confirm = 'Confirm';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String allDataDeleted = 'All data has been deleted.';
}
