/* ==========================================================
   CORPORATE MAIN DASHBOARD JS
   - sidebar toggle
   - active menu highlight
   - 공통 header/aside 연동
========================================================== */

/* ------------------------------
   1. 사이드바 열기/닫기
------------------------------ */
document.addEventListener("DOMContentLoaded", () => {
    const sidebar = document.querySelector(".sidebar");
    const hamburger = document.querySelector(".hamburger");

    if (hamburger) {
        hamburger.addEventListener("click", () => {
            hamburger.classList.toggle("open");
            sidebar.classList.toggle("active");
        });
    }
});


/* ------------------------------
   2. 메뉴 active 표시
   - 현재 URL 기준
------------------------------ */
function setActiveMenu() {
    const currentPath = window.location.pathname;
    const menuItems = document.querySelectorAll(".sidebar a");

    menuItems.forEach(item => {
        const href = item.getAttribute("href");
        if (!href) return;

        // 부분 매칭으로 간단하게 처리
        if (currentPath.includes(href)) {
            item.classList.add("active");
        } else {
            item.classList.remove("active");
        }
    });
}

document.addEventListener("DOMContentLoaded", setActiveMenu);


/* ------------------------------
   3. 헤더 초기화 함수
   (corporate_main.html 최하단에서 호출)
------------------------------ */
window.initAdminHeader = function(pageName) {
    // pageName: "home", "employee", "contribution" 등
    // 현재는 corporate_main에서 home만 사용

    const headerTitle = document.querySelector(".header-current-page");
    if (headerTitle) {
        headerTitle.textContent = pageName === "home" ? "기업 메인" : pageName;
    }
};


/* ------------------------------
   4. 사이드바 바깥 클릭 시 닫기
------------------------------ */
document.addEventListener("click", function(e) {
    const sidebar = document.querySelector(".sidebar");
    const hamburger = document.querySelector(".hamburger");

    if (!sidebar || !hamburger) return;

    const clickedInsideSidebar = sidebar.contains(e.target);
    const clickedHamburger = hamburger.contains(e.target);

    if (!clickedInsideSidebar && !clickedHamburger) {
        sidebar.classList.remove("active");
        hamburger.classList.remove("open");
    }
});
