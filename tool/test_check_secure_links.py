import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location(
    "check_secure_links", Path(__file__).with_name("check_secure_links.py")
)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class SecureLinksTest(unittest.TestCase):
    def test_flags_markdown_autolink_and_html_links(self):
        text = "a [x](http://a.dev)\n<http://b.dev>\n<img src=\"http://c.dev/i.png\">\n"
        self.assertEqual(
            [line for line, _ in MODULE.insecure_links(text)], [1, 2, 3]
        )

    def test_accepts_https_and_inline_code(self):
        text = "[x](https://a.dev) and `http://127.0.0.1:8081` or `127.0.0.1:8081`\n"
        self.assertEqual(MODULE.insecure_links(text), [])


if __name__ == "__main__":
    unittest.main()
