const files = [ /* dynamically filled in */ ];
const sidebar = document.getElementById("sidebar-list");

files.forEach(file => {
  fetch(`html_docs/${file}`)
    .then(res => res.text())
    .then(html => {
      const match = html.match(/<title>(.*?)<\/title>/i);
      const title = match ? match[1] : file;
      const li = document.createElement("li");
      li.innerHTML = `<a href="#" onclick="loadDoc('${file}')">${title}</a>`;
      sidebar.appendChild(li);
    });
});

