"""Regression cases for the import policy, including future barrel additions."""

import unittest

from check_dependency_imports import directive_issues


class DependencyImportsTest(unittest.TestCase):
    def test_open_barrel_is_rejected_even_without_a_current_collision(self):
        self.assertTrue(directive_issues("import 'package:material_ui/material_ui.dart';"))

    def test_hide_does_not_protect_against_new_upstream_names(self):
        self.assertTrue(directive_issues("import 'package:material_ui/material_ui.dart' hide RoundedPolygon;"))

    def test_prefix_alone_does_not_restrict_implicit_extensions(self):
        self.assertTrue(directive_issues("import 'package:material_new_shapes/material_new_shapes.dart' as shapes;"))

    def test_explicit_imports_and_exports_are_accepted(self):
        source = """
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:material_new_shapes/material_new_shapes.dart'
    as shapes show RoundedPolygon, Morph, MorphToPathExtension;
export 'package:material_new_shapes/material_new_shapes.dart' show RoundedPolygon;
"""
        self.assertEqual(directive_issues(source), [])

    def test_material_geometry_cannot_silently_replace_morph_geometry(self):
        self.assertTrue(directive_issues("import 'package:material_ui/material_ui.dart' show RoundedPolygon;"))
        self.assertEqual(directive_issues("import 'package:material_ui/material_ui.dart' as material show RoundedPolygon;"), [])

    def test_open_reexport_is_rejected(self):
        self.assertTrue(directive_issues("export 'package:material_ui/material_ui.dart';"))

    def test_private_dependency_paths_are_rejected(self):
        self.assertTrue(directive_issues("import 'package:material_ui/src/shapes/rounded_polygon.dart' as m show RoundedPolygon;"))

    def test_comments_and_embedded_dart_examples_are_ignored(self):
        source = """
// import 'package:material_ui/material_ui.dart';
/* outer /* nested */ import 'package:material_ui/material_ui.dart'; */
const example = \"\"\"import 'package:material_ui/material_ui.dart';\"\"\";
const raw = r\"import 'package:material_ui/material_ui.dart';\";
"""
        self.assertEqual(directive_issues(source), [])

    def test_multiline_directives_and_comments_are_supported(self):
        source = "import /* note */\n\"package:material_ui/material_ui.dart\"\n show /* note */ ColorScheme;"
        self.assertEqual(directive_issues(source), [])

    def test_conditional_import_cannot_bypass_the_policy(self):
        source = "import 'stub.dart' if (dart.library.io) 'package:material_ui/material_ui.dart';"
        self.assertTrue(directive_issues(source))

    def test_unrelated_dependencies_are_unchanged(self):
        self.assertEqual(directive_issues("import 'package:motor/motor.dart';"), [])


if __name__ == "__main__":
    unittest.main()
