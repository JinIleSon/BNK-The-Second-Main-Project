// info/guide/sidebar.js
document.addEventListener("DOMContentLoaded", () => {
  const titles = document.querySelectorAll(".menu-title");

  titles.forEach(title => {
    title.addEventListener("click", () => {
      const isActive = title.classList.contains("active");

      // 모든 메뉴 닫기
      titles.forEach(t => {
        t.classList.remove("active");
        const next = t.nextElementSibling;
        if (next && next.classList.contains("submenu")) {
          next.style.maxHeight = null;
        }
      });

      // 현재 클릭한 메뉴만 열기
      if (!isActive) {
        title.classList.add("active");
        const submenu = title.nextElementSibling;
        if (submenu && submenu.classList.contains("submenu")) {
          submenu.style.maxHeight = submenu.scrollHeight + "px";
        }
      }
    });
  });
});
