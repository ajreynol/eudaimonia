"""Integration checks for the published reports and their saved measurements."""

import csv
from html.parser import HTMLParser
import importlib.util
import json
from pathlib import Path
import re
import shutil
import tempfile
import unittest
from urllib.parse import unquote, urlsplit

spec = importlib.util.spec_from_file_location("build_site", Path(__file__).with_name("build-site.py"))
site = importlib.util.module_from_spec(spec)
spec.loader.exec_module(site)


class Links(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.links = []
        self.feed(text)

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name in ("href", "src"):
                self.links.append(value)


def chart_data(path):
    return json.loads(re.search(r"^const DATA = (.*);$", path.read_text(), re.M)[1])


class ReportSiteTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.temp.cleanup)
        cls.out = Path(cls.temp.name) / "public"
        cls.source = site.ROOT / "data/snapshots"
        cls.snapshots = site.build_site(cls.source, cls.out, "https://example.org/reports")

    def test_every_local_link_resolves_including_under_a_project_prefix(self):
        for page in self.out.rglob("*.html"):
            text = page.read_text()
            self.assertNotRegex(text, r"__[A-Z_]+__", page)
            for link in Links(text).links:
                parsed = urlsplit(link)
                if parsed.scheme or parsed.netloc or not parsed.path:
                    continue
                self.assertFalse(parsed.path.startswith("/"), (page, link))
                target = (page.parent / unquote(parsed.path)).resolve()
                self.assertTrue(target.is_relative_to(self.out), (page, link))
                self.assertTrue(target.is_file(), (page, link))

    def test_each_chart_and_download_matches_its_snapshot(self):
        for snapshot in self.snapshots:
            dest = self.out / "euthyna/snapshots" / snapshot["id"]
            with (snapshot["path"] / "rule-partition.csv").open() as handle:
                expected = {r["rule"]: r for r in csv.DictReader(handle)}
            data = chart_data(dest / "index.html")
            self.assertEqual(len(data), len(expected))
            for row in data:
                for field in ("order", "rule_loc", "proof_loc", "proof_files", "proof_reach_loc"):
                    self.assertEqual(row[field], int(expected[row["rule"]][field]))
            for name in site.DOWNLOADS:
                self.assertEqual((dest / name).read_bytes(), (snapshot["path"] / name).read_bytes())
            page = (dest / "index.html").read_text()
            self.assertIn(f'https://example.org/reports/euthyna/snapshots/{snapshot["id"]}/', page)
            if snapshot["meta"].get("logos_dirty"):
                self.assertIn("Measured with uncommitted Logos changes", page)

    def test_latest_advances_without_changing_older_measurements(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "snapshots"
            shutil.copytree(self.source, source)
            # Its name deliberately sorts before the existing snapshot names.
            new = source / "000-new-measurement"
            shutil.copytree(source / self.snapshots[0]["id"], new)
            meta = json.loads((new / "meta.json").read_text())
            meta["started"] = "2099-01-01T00:00:00Z"
            (new / "meta.json").write_text(json.dumps(meta))
            out = Path(directory) / "site"
            result = site.build_site(source, out, "https://example.org/reports")
            self.assertEqual(result[0]["id"], new.name)
            latest = out / "euthyna/index.html"
            self.assertIn("2099-01-01", latest.read_text())
            self.assertIn("snapshots/000-new-measurement/", latest.read_text())
            for old in self.snapshots:
                path = Path("euthyna/snapshots") / old["id"] / "index.html"
                self.assertEqual((out / path).read_bytes(), (self.out / path).read_bytes())

    def test_empty_or_incomplete_inputs_fail_before_writing_a_site(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "snapshots"
            source.mkdir()
            out = Path(directory) / "site"
            with self.assertRaisesRegex(ValueError, "no saved snapshots"):
                site.build_site(source, out, site.DEFAULT_URL)
            (source / "incomplete").mkdir()
            with self.assertRaisesRegex(ValueError, "incomplete snapshot"):
                site.build_site(source, out, site.DEFAULT_URL)
            self.assertFalse(out.exists())

    def test_output_cannot_overwrite_snapshot_inputs(self):
        for out in (self.source, self.source / "site", self.source.parent):
            with self.assertRaisesRegex(ValueError, "separate"):
                site.build_site(self.source, out, site.DEFAULT_URL)


if __name__ == "__main__":
    unittest.main()
