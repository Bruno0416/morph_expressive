import 'motion_catalog.dart';

// An assertion in a custom scroll position can leave a broken render tree.
// Keep this audit in its own Flutter test isolate so it cannot cascade into
// unrelated component families. Failures are still reported normally.
void main() => registerMotionCatalogTests(only: const {'carousel'});
