final List<String> motivationalTexts = [
  "Small steps build big confidence.",
  "Speak up, even if your voice shakes.",
  "Consistency beats motivation.",
  "Courage starts with one small action.",
  "Growth begins outside your comfort zone.",
  "Progress, not perfection.",
  "Listen more, talk smarter.",
  "Confidence is a skill, not a gift.",
  "Your effort compounds like interest.",
  "Every conversation is a chance to grow.",
  "Be curious, not judgmental.",
  "Small talk builds big bridges.",
  "Empathy is your hidden superpower.",
  "Take the first step; the rest will follow.",
  "Your words can open doors.",
  "Challenges are just skills in disguise.",
  "One skill at a time.",
  "Fail forward and learn faster.",
  "Soft skills create hard results.",
  "Your growth inspires others.",
  "Practice makes confidence.",
  "Be brave enough to start the talk.",
  "You can learn from every interaction.",
  "A smile is your strongest opener.",
  "Listen to understand, not to reply.",
  "Habits build mastery.",
  "It’s okay to be a beginner.",
  "Take action, fear will follow.",
  "Skills grow with attention and time.",
  "Your future self will thank you.",
];

String getRandomMotivation() {
  motivationalTexts.shuffle();
  return motivationalTexts.first;
}
