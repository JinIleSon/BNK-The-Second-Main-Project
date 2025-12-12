// ===============================
// BNK 공통 게시판 JS
// ===============================

// [1] 헤더·푸터 자동 로드
document.addEventListener("DOMContentLoaded", () => {
  const header = document.getElementById("header");
  const footer = document.getElementById("footer");

  if (header) {
    fetch("../../_header.html")
      .then((res) => res.text())
      .then((html) => (header.innerHTML = html))
      .catch((err) => console.error("Header load error:", err));
  }

  if (footer) {
    fetch("../../_footer.html")
      .then((res) => res.text())
      .then((html) => (footer.innerHTML = html))
      .catch((err) => console.error("Footer load error:", err));
  }

  initBoard();
});

// [2] 게시판 초기화
function initBoard() {
  const boardTable = document.querySelector(".board-list table");
  if (!boardTable) return;

  console.log("[Board] init success");

  // 클릭 이벤트 예시 (tr 클릭 시 상세로 이동)
  boardTable.querySelectorAll("tbody tr").forEach((row) => {
    const link = row.querySelector("a");
    if (link) {
      row.addEventListener("click", (e) => {
        if (e.target.tagName !== "A") link.click();
      });
    }
  });

  // 검색폼 이벤트
  const searchForm = document.querySelector("#boardSearchForm");
  if (searchForm) {
    searchForm.addEventListener("submit", (e) => {
      e.preventDefault();
      const query = searchForm.querySelector("input[name='keyword']").value.trim();
      if (!query) return;
      const boardCd = searchForm.dataset.boardcd;
      window.location.href = `/board/${boardCd}/list?keyword=${encodeURIComponent(query)}`;
    });
  }

  // 글쓰기 버튼 이벤트
  const writeBtn = document.querySelector("#writeBtn");
  if (writeBtn) {
    writeBtn.addEventListener("click", () => {
      const boardCd = writeBtn.dataset.boardcd;
      window.location.href = `/board/${boardCd}/write`;
    });
  }
}
