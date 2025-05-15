document.addEventListener("DOMContentLoaded", () => {
  const listContainer = document.getElementById("sidebar-list");
  const iframe = document.getElementById("docFrame");
  const filterInput = document.getElementById("filter");
  const defaultMessage = document.getElementById("defaultMessage");

  // Debug log
  console.log("Loaded files:", typeof files, files);

  if (typeof files !== 'object') {
    console.error("files is not defined or not an object");
    return;
  }

  function renderList(filter = "") {
    listContainer.innerHTML = "";

    Object.entries(files).forEach(([group, items]) => {
      const matched = items.filter(file =>
        file.title.toLowerCase().includes(filter.toLowerCase())
      );

      if (matched.length === 0) return;

      const heading = document.createElement("h3");
      heading.textContent = group;
      listContainer.appendChild(heading);

      const ul = document.createElement("ul");

      matched.forEach(file => {
        const li = document.createElement("li");
        const link = document.createElement("a");
        link.href = "#";
        link.textContent = file.title;
        link.addEventListener("click", () => {
          // Hide welcome message, show iframe
          if (defaultMessage) defaultMessage.style.display = "none";
          iframe.style.display = "block";
          iframe.src = file.path;
        });
        li.appendChild(link);
        ul.appendChild(li);
      });

      listContainer.appendChild(ul);
    });
  }

  renderList();

  filterInput.addEventListener("input", (e) => {
    renderList(e.target.value);
  });

  const toggleBtn = document.getElementById("toggle-sidebar");
  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      document.getElementById("sidebar").classList.toggle("collapsed");
    });
  }
});
