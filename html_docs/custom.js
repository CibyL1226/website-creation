const sidebarList = document.getElementById("sidebar-list");
const htmlFrame = document.getElementById("htmlFrame");
const pdfEmbed = document.getElementById("pdfEmbed");
const imageViewer = document.getElementById("imageViewer");
const defaultContent = document.getElementById("default-content");
const searchBox = document.getElementById("filter");

function hideAllViewers() {
  htmlFrame.style.display = "none";
  pdfEmbed.style.display = "none";
  imageViewer.style.display = "none";
  defaultContent.style.display = "none";
}

function getFileExtension(filename) {
  return filename.split(".").pop().toLowerCase();
}

// Populate the sidebar
Object.keys(files).forEach(group => {
  // Group heading
  const groupHeader = document.createElement("li");
  groupHeader.innerHTML = `<strong>${group}</strong>`;
  sidebarList.appendChild(groupHeader);

  // Each file in the group
  files[group].forEach(file => {
    const li = document.createElement("li");
    const link = document.createElement("a");
    link.href = "#";
    link.textContent = file.title;

    link.onclick = () => {
      hideAllViewers();
      const ext = getFileExtension(file.path);

      if (["html", "htm"].includes(ext)) {
        htmlFrame.src = file.path;
        htmlFrame.style.display = "block";
      } else if (ext === "pdf") {
        pdfEmbed.src = file.path;
        pdfEmbed.style.display = "block";
      } else if (["png", "jpg", "jpeg", "gif", "bmp", "svg", "webp"].includes(ext)) {
        imageViewer.src = file.path;
        imageViewer.style.display = "block";
      } else {
        // Default fallback: try iframe
        htmlFrame.src = file.path;
        htmlFrame.style.display = "block";
      }
    };

    li.appendChild(link);
    sidebarList.appendChild(li);
  });
});

// Search filter
searchBox.addEventListener("input", () => {
  const query = searchBox.value.toLowerCase();
  const items = sidebarList.querySelectorAll("li");

  items.forEach(li => {
    const text = li.textContent.toLowerCase();
    const isHeader = li.querySelector("strong") !== null;

    // Show all group headers
    if (isHeader) {
      li.style.display = "";
    } else {
      li.style.display = text.includes(query) ? "" : "none";
    }
  });
});
