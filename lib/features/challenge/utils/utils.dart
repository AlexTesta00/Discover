Set<String> _normAll(Iterable<String> xs) =>
    xs.map((s) => s.toLowerCase()
      .replaceAll(RegExp(r"[àáâãä]"), "a")
      .replaceAll(RegExp(r"[èéêë]"), "e")
      .replaceAll(RegExp(r"[ìíîï]"), "i")
      .replaceAll(RegExp(r"[òóôõö]"), "o")
      .replaceAll(RegExp(r"[ùúûü]"), "u")
      .replaceAll(RegExp(r"[^a-z0-9 ]"), " ")
      .replaceAll(RegExp(r"\s+"), " ")
    ).toSet();

bool anyLabelMatches({
  required Iterable<String> mlLabels,
  required Iterable<String> challengeLabels,
}) {
  final ml = _normAll(mlLabels);
  final ch = _normAll(challengeLabels);
  return ml.intersection(ch).isNotEmpty;
}
