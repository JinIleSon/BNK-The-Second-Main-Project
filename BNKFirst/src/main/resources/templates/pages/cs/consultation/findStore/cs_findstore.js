//////////////////////////////////
//header & footer 
//////////////////////////////////

// header 불러오기
fetch('/layouts/header.html')
  .then(response => response.text())
  .then(data => {
    document.getElementById('header').innerHTML = data;
  })
  .catch(err => console.error('[Header load failed]', err));

// chatbot import 기능
async function importHtmlWithAssets(url, mountSelector) {
  try {
    const res = await fetch(url, { credentials: 'same-origin' });
    if (!res.ok) throw new Error(`Failed to load ${url}`);
    const html = await res.text();

    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');

    doc.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
      const href = link.getAttribute('href');
      const exists = [...document.head.querySelectorAll('link[rel="stylesheet"]')]
        .some(l => l.getAttribute('href') === href);
      if (!exists && href) document.head.appendChild(link.cloneNode(true));
    });

    doc.querySelectorAll('style').forEach(styleEl => {
      const clone = document.createElement('style');
      clone.textContent = styleEl.textContent;
      [...styleEl.attributes].forEach(a => clone.setAttribute(a.name, a.value));
      document.head.appendChild(clone);
    });

    const mount = document.querySelector(mountSelector);
    const frag = document.createDocumentFragment();
    [...doc.body.children].forEach(node => {
      if (node.tagName.toLowerCase() !== 'script') frag.appendChild(node.cloneNode(true));
    });
    mount.appendChild(frag);

    const scripts = [...doc.querySelectorAll('script')];
    for (const oldScript of scripts) {
      const newScript = document.createElement('script');
      [...oldScript.attributes].forEach(attr => newScript.setAttribute(attr.name, attr.value));
      if (oldScript.src) {
        await new Promise(resolve => {
          newScript.onload = resolve;
          newScript.onerror = resolve;
          document.body.appendChild(newScript);
        });
      } else {
        newScript.textContent = oldScript.textContent || '';
        document.body.appendChild(newScript);
      }
    }
  } catch (err) {
    console.error('[Chatbot load failed]', err);
  }
}

// chatbot 불러오기
importHtmlWithAssets('/components/chatbot_test.html', '#bnk-chatbot-slot');

// footer 불러오기
fetch('/layouts/footer.html')
  .then(response => response.text())
  .then(data => {
    document.getElementById('footer').innerHTML = data;
  })
  .catch(err => console.error('[Footer load failed]', err));


//////////////////////////////////
// 더미데이터
//////////////////////////////////
const storeData = [
  { name: "가야동지점", addr: "부산광역시 부산진구 가야대로 610 (가야동)", tel: "051-892-3651", fax: "051-608-5043" },
  { name: "개금동지점", addr: "부산광역시 부산진구 가야대로 494 (개금동)", tel: "051-891-4001", fax: "051-608-5060" },
  { name: "감천동지점", addr: "부산광역시 사하구 옥천로 6 (감천동)", tel: "051-204-1011", fax: "051-608-5084" },
  { name: "감만동영업소", addr: "부산 남구 유암로 124 홈플러스 감만점 1층", tel: "051-642-5421", fax: "051-608-5094" },
  { name: "감전동금융센터", addr: "부산광역시 사상구 새벽로 160 (감전동)", tel: "051-312-5301", fax: "051-608-5100" },
  { name: "강남금융센터", addr: "서울특별시 서초구 강남대로 279 (서초동)", tel: "02-598-6191", fax: "051-608-5103" },
  { name: "거제고현지점", addr: "경남 거제시 거제중앙로 292길 15 (고현동)", tel: "055-635-9100", fax: "055-635-9146" },
  { name: "개금사랑영업소", addr: "부산광역시 부산진구 복지로 49 (개금동)", tel: "051-891-7007", fax: "051-608-5208" },
  { name: "감천조양지점", addr: "부산광역시 사하구 감천로 67 (감천동)", tel: "051-204-2222", fax: "051-608-5300" },
];

//////////////////////////////////
// pagination
//////////////////////////////////
const rowsPerPage = 5;
let currentPage = 1;

const tbody = document.querySelector(".store-table tbody");
const pagination = document.querySelector(".pagination");
const totalCount = document.querySelector(".consultation-list-top strong:first-child");
const pageInfo = document.querySelector(".consultation-list-top strong:last-child");

// 테이블 렌더링
function renderTable(page) {
  tbody.innerHTML = "";

  const start = (page - 1) * rowsPerPage;
  const end = start + rowsPerPage;
  const pageData = storeData.slice(start, end);

  pageData.forEach(store => {
    const row = `
      <tr>
        <td>${store.name}<br><button class="detail-btn">상세보기</button></td>
        <td>${store.addr}</td>
        <td>${store.tel}</td>
        <td>${store.fax}</td>
      </tr>
    `;
    tbody.insertAdjacentHTML("beforeend", row);
  });

  totalCount.textContent = storeData.length;
  pageInfo.textContent = `${page}/${Math.ceil(storeData.length / rowsPerPage)}`;
}

// 페이지네이션 렌더링
function renderPagination() {
  pagination.innerHTML = "";
  const totalPages = Math.ceil(storeData.length / rowsPerPage);

  // 처음으로
  const firstBtn = document.createElement("button");
  firstBtn.innerHTML = '<i class="fas fa-angle-double-left"></i>';
  firstBtn.disabled = currentPage === 1;
  firstBtn.addEventListener("click", () => {
    currentPage = 1;
    updatePage();
  });
  pagination.appendChild(firstBtn);

  // 숫자 버튼
  for (let i = 1; i <= totalPages; i++) {
    const btn = document.createElement("button");
    btn.textContent = i;
    if (i === currentPage) btn.classList.add("active");
    btn.addEventListener("click", () => {
      currentPage = i;
      updatePage();
    });
    pagination.appendChild(btn);
  }

  // 마지막으로
  const lastBtn = document.createElement("button");
  lastBtn.innerHTML = '<i class="fas fa-angle-double-right"></i>';
  lastBtn.disabled = currentPage === totalPages;
  lastBtn.addEventListener("click", () => {
    currentPage = totalPages;
    updatePage();
  });
  pagination.appendChild(lastBtn);
}

// 갱신
function updatePage() {
  renderTable(currentPage);
  renderPagination();
}

// 초기 실행
document.addEventListener("DOMContentLoaded", () => {
  updatePage();
});