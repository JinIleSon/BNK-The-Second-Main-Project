// ===============================
// BNK 공통 게시판 JS
// ===============================
document.addEventListener("DOMContentLoaded", () => {
  const header = document.getElementById("header");
  const footer = document.getElementById("footer");

  // ✅ 현재 URL이 /BNK로 시작하면 자동 인식
  const contextPath = window.location.pathname.startsWith("/BNK") ? "/BNK" : "";

const contextPath = window.location.pathname.startsWith("/BNK") ? "/BNK" : "";

if (header) {
  fetch(`${contextPath}/layouts/info/_header.html`)
    .then(res => res.text())
    .then(html => (header.innerHTML = html))
    .catch(err => console.error("Header load error:", err));
}

if (footer) {
  fetch(`${contextPath}/layouts/info/_footer.html`)
    .then(res => res.text())
    .then(html => (footer.innerHTML = html))
    .catch(err => console.error("Footer load error:", err));
}


  initBoard(contextPath);
});
