import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location(
    "check_button_surface_docs",
    Path(__file__).with_name("check_button_surface_docs.py"),
)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ButtonSurfaceDocsTest(unittest.TestCase):
    def test_flags_button_calls_with_surface(self):
        text = (
            "MorphButton.outlined(\n  variant: .danger,\n  surface: .frosted,\n"
            "  onPressed: f,\n  child: const Text('x'),\n);\n"
            "const MorphIconButton.filled(surface: MorphSurface.frosted);\n"
            "MorphAsyncButton(label: 'a', surface: .frosted);\n"
            "MorphButton.icon(icon: i, label: l, surface: .frosted);\n"
        )
        self.assertEqual(
            [line for line, _ in MODULE.button_surface_calls(text)],
            [1, 7, 8, 9],
        )

    def test_flags_dartdoc_prefixed_calls(self):
        text = "/// ```dart\n/// MorphButton.text(surface: .frosted)\n/// ```\n"
        self.assertEqual(len(MODULE.button_surface_calls(text)), 1)

    def test_accepts_cards_variants_and_prose(self):
        text = (
            "MorphCard.outlined(surface: .frosted, child: c);\n"
            "MorphButton.outlined(variant: .danger, onPressed: f);\n"
            "Frosted surface is a card finish; buttons take variant.\n"
            "MorphButtonGroup(surface: x)\n"
        )
        self.assertEqual(MODULE.button_surface_calls(text), [])

    def test_ignores_surface_in_nested_arguments_and_strings(self):
        text = (
            "MorphButton(onPressed: f, child: MorphCard(surface: .frosted));\n"
            "MorphButton(onPressed: f, child: const Text('surface: x'));\n"
        )
        self.assertEqual(MODULE.button_surface_calls(text), [])

    def test_repository_documentation_is_clean(self):
        self.assertEqual(MODULE.main(), 0)


if __name__ == "__main__":
    unittest.main()
