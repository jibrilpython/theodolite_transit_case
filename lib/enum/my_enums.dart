enum InstrumentType {
  theodolite('Theodolite'),
  transit('Transit'),
  dumpyLevel('Dumpy Level'),
  tiltingLevel('Tilting Level'),
  alidade('Alidade'),
  sextant('Sextant'),
  tachymeter('Tachymeter'),
  other('Other');

  const InstrumentType(this.label);
  final String label;
}

enum ConditionState {
  museumDisplay('Museum Display Quality'),
  functional('Functional'),
  smooth('Axis Movement Smooth'),
  frozen('Axis Movement Frozen'),
  unknown('Unknown');

  const ConditionState(this.label);
  final String label;
}
