/// 30+ built-in positive affirmations (EN & ID).
library;

import '../services/locale_service.dart';

const List<String> _affirmationsEn = [
  'I am worthy of love, peace, and joy.',
  'Every day I grow stronger and more resilient.',
  'I choose to focus on what I can control.',
  'My mind is calm, my heart is full.',
  'I am capable of handling whatever comes my way.',
  'Today, I choose to be kind to myself.',
  'I release the need to be perfect.',
  'My feelings are valid and I honor them.',
  'I am proud of how far I have come.',
  'Small steps every day lead to big changes.',
  'I deserve rest and self-care.',
  'I am not defined by my past.',
  'Peace begins with me.',
  'I trust the journey of my life.',
  'I am enough, exactly as I am.',
  'Gratitude transforms my perspective.',
  'I give myself permission to heal.',
  'My voice matters and my thoughts are important.',
  'I am surrounded by love and support.',
  'Challenges help me grow and learn.',
  'I choose hope over fear.',
  'My potential is limitless.',
  'I am gentle with myself during difficult times.',
  'Today is a new opportunity to begin again.',
  'I radiate confidence and positivity.',
  'I am in charge of my own happiness.',
  'Letting go is an act of strength.',
  'I embrace the present moment fully.',
  'I am creating a life I love.',
  'My mind is a place of peace and clarity.',
  'I am deserving of good things.',
  'Healing is not linear, and that is okay.',
  'I choose to see the good in myself and others.',
  'I am stronger than my worries.',
  'Every breath I take brings me calm.',
  'I am building a healthier relationship with myself.',
];

const List<String> _affirmationsId = [
  'Aku layak mendapatkan cinta, kedamaian, dan kebahagiaan.',
  'Setiap hari aku tumbuh lebih kuat dan tangguh.',
  'Aku memilih fokus pada hal yang bisa aku kendalikan.',
  'Pikiranku tenang, hatiku penuh.',
  'Aku mampu menghadapi apa pun yang datang.',
  'Hari ini, aku memilih untuk baik pada diriku sendiri.',
  'Aku melepaskan kebutuhan untuk menjadi sempurna.',
  'Perasaanku valid dan aku menghormatinya.',
  'Aku bangga dengan seberapa jauh aku telah melangkah.',
  'Langkah kecil setiap hari membawa perubahan besar.',
  'Aku berhak untuk istirahat dan merawat diri.',
  'Aku tidak ditentukan oleh masa laluku.',
  'Kedamaian dimulai dari diriku.',
  'Aku percaya pada perjalanan hidupku.',
  'Aku cukup, persis seperti diriku sekarang.',
  'Rasa syukur mengubah cara pandangku.',
  'Aku memberi diriku izin untuk pulih.',
  'Suaraku berarti dan pikiranku penting.',
  'Aku dikelilingi oleh cinta dan dukungan.',
  'Tantangan membantuku tumbuh dan belajar.',
  'Aku memilih harapan di atas ketakutan.',
  'Potensiku tidak terbatas.',
  'Aku lembut pada diriku sendiri di saat-saat sulit.',
  'Hari ini adalah kesempatan baru untuk memulai lagi.',
  'Aku memancarkan kepercayaan diri dan hal positif.',
  'Aku bertanggung jawab atas kebahagiaanku sendiri.',
  'Melepaskan adalah tindakan kekuatan.',
  'Aku merangkul momen saat ini sepenuhnya.',
  'Aku sedang menciptakan hidup yang aku cintai.',
  'Pikiranku adalah tempat kedamaian dan kejelasan.',
  'Aku layak mendapatkan hal-hal baik.',
  'Pemulihan tidak linear, dan itu tidak apa-apa.',
  'Aku memilih melihat kebaikan dalam diriku dan orang lain.',
  'Aku lebih kuat dari kekhawatiranku.',
  'Setiap napas yang kuambil memberiku ketenangan.',
  'Aku sedang membangun hubungan yang lebih sehat dengan diriku sendiri.',
];

/// Returns the affirmation list for the current language.
List<String> get affirmations {
  return L10n.isIndonesian ? _affirmationsId : _affirmationsEn;
}

/// Legacy reference for backward compatibility.
const List<String> builtInAffirmations = _affirmationsEn;
