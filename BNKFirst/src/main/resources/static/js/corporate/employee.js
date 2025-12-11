/* ==========================================================
   EMPLOYEE LIST PAGE SCRIPT
   - employee table rendering
   - detail card rendering
   - search & filter
   - sidebar toggle
   - menu active
========================================================== */

document.addEventListener("DOMContentLoaded", () => {
    initSidebar();
    setActiveMenu();
    initEmployeeListPage();
});

/* ==========================================================
   1. 사이드바 토글 기능
========================================================== */
function initSidebar() {
    const sidebar = document.querySelector(".sidebar");
    const hamburger = document.querySelector(".hamburger");

    if (!hamburger || !sidebar) return;

    hamburger.addEventListener("click", () => {
        hamburger.classList.toggle("open");
        sidebar.classList.toggle("active");
    });

    // 바깥 클릭 시 닫기
    document.addEventListener("click", (e) => {
        const insideSidebar = sidebar.contains(e.target);
        const insideHamburger = hamburger.contains(e.target);

        if (!insideSidebar && !insideHamburger) {
            sidebar.classList.remove("active");
            hamburger.classList.remove("open");
        }
    });
}

/* ==========================================================
   2. 현재 메뉴 active 표시
========================================================== */
function setActiveMenu() {
    const currentPath = window.location.pathname;
    const menuItems = document.querySelectorAll(".sidebar a");

    menuItems.forEach(item => {
        const href = item.getAttribute("href");
        if (href && currentPath.includes(href)) {
            item.classList.add("active");
        } else {
            item.classList.remove("active");
        }
    });
}

/* ==========================================================
   3. 직원 목록 페이지 초기화
========================================================== */
function initEmployeeListPage() {
    const employees = window.employees || [];   // list.html에서 정의한 더미

    const tbody = document.getElementById("employeeTbody");
    const detailArea = document.getElementById("detailArea");

    const searchInput = document.getElementById("searchInput");
    const planFilter = document.getElementById("planFilter");
    const resetBtn = document.getElementById("resetBtn");

    renderTable(employees, tbody, detailArea);

    searchInput.addEventListener("input", () =>
        applyFilter(employees, tbody, detailArea, searchInput, planFilter));

    planFilter.addEventListener("change", () =>
        applyFilter(employees, tbody, detailArea, searchInput, planFilter));

    resetBtn.addEventListener("click", () => {
        searchInput.value = "";
        planFilter.value = "";
        renderTable(employees, tbody, detailArea);
    });
}

/* ==========================================================
   4. 테이블 렌더링
========================================================== */
function renderTable(list, tbody, detailArea) {
    tbody.innerHTML = "";

    if (!list.length) {
        const tr = document.createElement("tr");
        tr.innerHTML = `<td colspan="5" class="empty-text">조건에 맞는 직원이 없습니다.</td>`;
        tbody.appendChild(tr);
        detailArea.innerHTML = `<p class="empty-text">왼쪽 목록에서 직원을 선택하면 상세정보가 표시됩니다.</p>`;
        return;
    }

    list.forEach(emp => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${emp.empId}</td>
            <td>${emp.name}</td>
            <td>
                <span class="tag ${emp.planType === "DB" ? "tag-db" : "tag-dc"}">
                    ${emp.planType}
                </span>
            </td>
            <td>${emp.accountNo}</td>
            <td class="${emp.status === "ACTIVE" ? "status-active" : "status-retired"}">
                ${emp.status === "ACTIVE" ? "재직" : "퇴사"}
            </td>
        `;

        tr.addEventListener("click", () => renderDetail(emp, detailArea));

        tbody.appendChild(tr);
    });

    detailArea.innerHTML = `<p class="empty-text">왼쪽 목록에서 직원을 선택하면 상세정보가 표시됩니다.</p>`;
}

/* ==========================================================
   5. 상세 정보 렌더링
========================================================== */
function renderDetail(emp, detailArea) {
    detailArea.innerHTML = `
        <div class="detail-row">
            <div class="detail-label">직원 ID</div>
            <div class="detail-value">${emp.empId}</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">직원 이름</div>
            <div class="detail-value">${emp.name}</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">제도 유형</div>
            <div class="detail-value">${emp.planType}</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">계좌번호</div>
            <div class="detail-value">${emp.accountNo}</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">재직 상태</div>
            <div class="detail-value">
                ${emp.status === "ACTIVE" ? "재직" : "퇴사"}
            </div>
        </div>

        <div class="balance-box">
            <div class="balance-label">현재 적립금</div>
            <div class="balance-value">
                ${formatMoney(emp.balance)}
            </div>
        </div>
    `;
}

/* ==========================================================
   6. 검색 & 필터
========================================================== */
function applyFilter(employees, tbody, detailArea, searchInput, planFilter) {
    const keyword = searchInput.value.trim();
    const plan = planFilter.value;

    const filtered = employees.filter(emp => {
        const matchPlan = plan ? emp.planType === plan : true;
        const matchKeyword = keyword
            ? (emp.name.includes(keyword) || emp.accountNo.includes(keyword))
            : true;

        return matchPlan && matchKeyword;
    });

    renderTable(filtered, tbody, detailArea);
}

/* ==========================================================
   7. 금액 포맷 함수
========================================================== */
function formatMoney(amount) {
    return amount.toLocaleString("ko-KR") + "원";
}
