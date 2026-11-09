
class RecipeImportResult {
  final int imported;
  final int skipped;
  final int failed;

  const RecipeImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });
}
