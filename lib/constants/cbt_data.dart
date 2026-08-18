/// 10 cognitive distortions and 30 CBT tips.
library;

/// A single cognitive distortion with its name and description.
class CognitiveDistortion {
  final String name;
  final String description;
  final String example;

  const CognitiveDistortion({
    required this.name,
    required this.description,
    required this.example,
  });
}

/// The 10 most common cognitive distortions.
const List<CognitiveDistortion> cognitiveDistortions = [
  CognitiveDistortion(
    name: 'All-or-Nothing Thinking',
    description: 'Seeing things in black-and-white categories.',
    example:
        '"If I make one mistake, I\'m a total failure."',
  ),
  CognitiveDistortion(
    name: 'Overgeneralization',
    description: 'Seeing a single negative event as a never-ending pattern.',
    example:
        '"This always happens to me. Nothing ever goes right."',
  ),
  CognitiveDistortion(
    name: 'Mental Filter',
    description: 'Dwelling on one negative detail while ignoring the positives.',
    example:
        '"I got 9 compliments but I can\'t stop thinking about that 1 criticism."',
  ),
  CognitiveDistortion(
    name: 'Discounting the Positive',
    description: 'Rejecting positive experiences as if they "don\'t count."',
    example:
        '"They only said that to be nice. It doesn\'t really mean anything."',
  ),
  CognitiveDistortion(
    name: 'Jumping to Conclusions',
    description: 'Mind reading or fortune telling without evidence.',
    example:
        '"They didn\'t reply to my text. They must be mad at me."',
  ),
  CognitiveDistortion(
    name: 'Magnification (Catastrophizing)',
    description: 'Blowing things out of proportion.',
    example:
        '"I have a headache. What if it\'s something really serious?"',
  ),
  CognitiveDistortion(
    name: 'Emotional Reasoning',
    description: 'Assuming your feelings reflect the truth.',
    example:
        '"I feel anxious, so something bad must be about to happen."',
  ),
  CognitiveDistortion(
    name: 'Should Statements',
    description: 'Using "should," "must," or "ought to" against yourself.',
    example:
        '"I should always be productive. I must never make mistakes."',
  ),
  CognitiveDistortion(
    name: 'Labeling',
    description: 'Attaching a negative label to yourself or others.',
    example:
        '"I forgot the meeting. I\'m such an idiot."',
  ),
  CognitiveDistortion(
    name: 'Personalization',
    description: 'Blaming yourself for things outside your control.',
    example:
        '"My friend seems upset. It must be something I did."',
  ),
];

/// 30+ CBT educational tips.
const List<String> cbtTips = [
  'Thoughts are not facts — they are just thoughts.',
  'Challenge negative thoughts by asking: "What\'s the evidence?"',
  'Separate what happened from your interpretation of what happened.',
  'Ask yourself: "What would I tell a friend in this situation?"',
  'Emotions are temporary visitors. They come and they go.',
  'You can\'t control everything, but you can control your response.',
  'A thought is just a mental event, not a reflection of reality.',
  'Practice self-compassion: treat yourself like you\'d treat a friend.',
  'Notice when you\'re using "should" statements — question them.',
  'The worst-case scenario is rarely the most likely scenario.',
  'Your worth is not defined by your productivity.',
  'Small steps forward are still progress.',
  'Avoidance fuels anxiety. Facing fears reduces them.',
  'What you resist persists. Acknowledge your feelings.',
  'Reframe: turn "I have to" into "I get to" or "I choose to."',
  'Your past mistakes don\'t define your future.',
  'Perfectionism is the enemy of progress.',
  'Compare yourself only to who you were yesterday.',
  'Feelings are valid, but they don\'t always tell the truth.',
  'When you catch yourself catastrophizing, ask: "And then what?"',
  'You are not your thoughts. You are the observer of your thoughts.',
  'Gratitude and anxiety cannot occupy the same space.',
  'Setbacks are setups for comebacks.',
  'The mind is like a garden — tend to it daily.',
  'You have survived 100% of your bad days so far.',
  'Action precedes motivation, not the other way around.',
  'Breathe. Pause. Respond. Don\'t react.',
  'What you focus on grows. Focus on what\'s going right.',
  'Be curious about your emotions instead of judgmental.',
  'Your anxiety is lying to you. Check the facts.',
  'Self-care is not selfish — it\'s necessary.',
  'Uncertainty is not danger. It\'s just uncertainty.',
  'You are allowed to rest without feeling guilty.',
  'Progress, not perfection.',
  'The quality of your thoughts determines the quality of your life.',
];