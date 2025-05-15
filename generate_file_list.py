import os
from bs4 import BeautifulSoup

# Paths
base_dir = "html_docs"
output_path = os.path.join(base_dir, "file_list.js")

# Hold raw entries
file_entries = []

# === Part 1: Extract and rename titles from HTML/HTM ===
for root, dirs, files in os.walk(base_dir):
    for f in files:
        if f.endswith((".html", ".htm")) and f != "viewer.html":
            rel_path = os.path.relpath(os.path.join(root, f), base_dir)
            full_path = os.path.join(root, f)

            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as html_file:
                    soup = BeautifulSoup(html_file, "html.parser")
                    title = soup.title.string.strip() if soup.title and soup.title.string else f
            except Exception:
                title = f

            file_entries.append({
                "path": rel_path.replace("\\", "/"),
                "title": title
            })

# === Part 2: Group files by renamed title ===

# Buckets for groupings
grouped = {
    "Data Files": [],
    "CTL Files": [],
    "PPP Files": [],
    "FOR Files": [],
    "EXA Files": [],
    "Other Files": []
}

# Determine group based on renamed title
def guess_group_by_title(title):
    if title.endswith(".dat"):
        return "Data Files"
    elif title.endswith(".ctl"):
        return "CTL Files"
    elif title.endswith(".ppp"):
        return "PPP Files"
    elif title.endswith(".for"):
        return "FOR Files"
    elif title.endswith(".exa"):
        return "EXA Files"
    else:
        return "Other Files"

# Assign each entry to a group
for entry in file_entries:
    group = guess_group_by_title(entry["title"])
    grouped[group].append(entry)

# === Final Output ===

with open(output_path, "w", encoding="utf-8") as out:
    out.write("const files = {\n")
    for group_name, entries in grouped.items():
        out.write(f'  "{group_name}": [\n')
        for entry in entries:
            out.write(f'    {{ path: "{entry["path"]}", title: "{entry["title"]}" }},\n')
        out.write("  ],\n")
    out.write("};\n")
