import os
from bs4 import BeautifulSoup

base_dir = "html_docs"
output_file = os.path.join(base_dir, "file_list.js")

# Define groups
grouped = {
    "Data Files": [],
    "HTML Files": [],
    "Special ($) Files": [],
    "PDF Files": [],
    "PPP Files": [],
    "CTL Files": [],
    "FOR Files": [],
    "EXA Files": [],
    "Other Files": []
}

# Extensions to skip entirely (all image types)
exclude_exts = [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg", ".webp"]

def get_title_html(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            soup = BeautifulSoup(f.read(), "html.parser")
            if soup.title and soup.title.string:
                return soup.title.string.strip()
    except Exception:
        pass
    return os.path.basename(filepath)

for root, _, files in os.walk(base_dir):
    for name in files:
        if name == "viewer.html" or name == "file_list.js":
            continue

        ext = os.path.splitext(name)[1].lower()
        if ext in exclude_exts:
            continue  # ⛔️ Skip images

        full_path = os.path.join(root, name)
        rel_path = os.path.relpath(full_path, base_dir).replace("\\", "/")
        title = name

        # Group logic
        if name.lower().endswith(".dat"):
            group = "Data Files"

        elif name.lower().endswith((".html", ".htm")) and name[0].isdigit():
            group = "HTML Files"
            title = get_title_html(full_path)

        elif name.startswith("$"):
            group = "Special ($) Files"

        elif ext == ".pdf":
            group = "PDF Files"
            title = f"PDF: {name}"

        else:
            group = "Other Files"

        grouped[group].append({ "path": rel_path, "title": title })

# Write JavaScript
with open(output_file, "w", encoding="utf-8") as f:
    f.write("const files = {\n")
    for group_name, entries in grouped.items():
        f.write(f'  "{group_name}": [\n')
        for entry in entries:
            f.write(f'    {{ path: "{entry["path"]}", title: "{entry["title"]}" }},\n')
        f.write("  ],\n")
    f.write("};\n")
