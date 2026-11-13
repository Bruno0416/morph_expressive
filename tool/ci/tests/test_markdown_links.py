"""Regression checks for local documentation references, without network I/O."""
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from check_markdown_links import missing_targets


class MarkdownLinksTest(unittest.TestCase):
    def test_relative_images_references_html_and_url_encoded_paths(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'doc').mkdir()
            (root / 'LICENSE').write_text('license')
            (root / 'doc/my guide.md').write_text('guide')
            (root / 'doc/image.png').write_bytes(b'image')
            file = root / 'doc/README.md'
            file.write_text('''[License](../LICENSE#terms)
![Preview](image.png)
[Guide](<my guide.md>)
[Encoded](my%20guide.md?raw=1)
[reference]: ../LICENSE "title"
<img src="image.png">
[Remote](https://example.invalid/anything)
[Heading](#heading)
''')
            self.assertEqual([], missing_targets(root, file))

    def test_missing_assets_and_targets_outside_repository_fail(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            file = root / 'README.md'
            file.write_text('![Missing](missing.gif)\n[Outside](../outside.md)\n')
            self.assertEqual(['missing.gif', '../outside.md'], missing_targets(root, file))

    def test_code_examples_are_not_interpreted_as_document_links(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            file = root / 'README.md'
            file.write_text('''`[literal](not-a-file.md)`
```md
[example](example-only.md)
```
~~~md
![example](another-example.png)
~~~
''')
            self.assertEqual([], missing_targets(root, file))


if __name__ == '__main__':
    unittest.main()
