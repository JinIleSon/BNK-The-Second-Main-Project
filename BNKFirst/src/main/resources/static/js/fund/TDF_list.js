document.addEventListener('DOMContentLoaded', () => {
    /* ---- 예시 데이터 (백엔드 연동 시 이 부분을 API 응답으로 대체) ---- */
    // const PRODUCTS = [
    //     { id: 1, type: '정기예금', name: 'BNK 플러스 정기예금', baseRate: 3.5, bonusRate: 0.7, term: '6~36개월', join: ['인터넷', '영업점'], benefits: ['자동이체 +0.3%'], releasedAt: '2024-07-10' },
    //     { id: 2, type: '정기예금', name: 'BNK 프리미엄 정기예금', baseRate: 3.8, bonusRate: 0.7, term: '12~24개월', join: ['인터넷', '영업점'], benefits: ['급여이체 +0.5%'], releasedAt: '2024-10-15' },
    //     { id: 3, type: '정기예금', name: 'BNK 스마트 정기예금', baseRate: 3.3, bonusRate: 0.5, term: '3~12개월', join: ['인터넷'], benefits: ['모바일 가입 +0.2%'], releasedAt: '2024-05-30' },
    //     { id: 4, type: '정기예금', name: 'BNK 자유적립 정기예금', baseRate: 3.1, bonusRate: 0.5, term: '6~36개월', join: ['인터넷', '영업점'], benefits: ['자동이체 +0.3%'], releasedAt: '2023-12-20' },
    //     { id: 5, type: '정기예금', name: 'BNK 만기이자지급식 예금', baseRate: 3.4, bonusRate: 0.5, term: '12~24개월', join: ['인터넷', '영업점'], benefits: ['카드사용 +0.2%'], releasedAt: '2024-03-18' },
    //     { id: 6, type: '정기예금', name: 'BNK 정기예금(특판)', baseRate: 3.6, bonusRate: 0.9, term: '6~12개월', join: ['인터넷'], benefits: ['신규우대 +0.3%'], releasedAt: '2024-11-01' },
    //     { id: 7, type: '정기예금', name: 'BNK e-정기예금', baseRate: 3.2, bonusRate: 0.6, term: '12~36개월', join: ['인터넷'], benefits: ['자동이체 +0.3%'], releasedAt: '2022-09-10' },
    //     { id: 8, type: '정기예금', name: 'BNK 프리미엄Plus', baseRate: 3.7, bonusRate: 0.6, term: '3~24개월', join: ['영업점'], benefits: ['급여이체 +0.4%'], releasedAt: '2024-08-05' },
    //     { id: 9, type: '정기예금', name: 'BNK 스텝업예금', baseRate: 3.1, bonusRate: 0.7, term: '6~24개월', join: ['인터넷', '영업점'], benefits: ['잔액유지 +0.2%'], releasedAt: '2024-01-25' },
    // ].map(p => ({ ...p, maxRate: +(p.baseRate + p.bonusRate).toFixed(2) }));

    /* ================= 상태 ================= */
    let view = 'grid';               // 'grid' | 'list'
    let sortKey = 'join_internet';   // 서버가 지원하도록 맞춰 주세요
    let keyword = "";
    let page = 1;
    const pageSize = 6;

    /* ================= DOM ================= */
    const container = document.getElementById('container');
    const pager = document.getElementById('pagination');
    const totalEl = document.getElementById('totalCount');

    /* ================= 칩(필터) 정의/렌더: 기존 그대로 사용 ================= */
    const CHIP_GROUPS = [
        {
              id: 'operator', label: '운용사', field: 'operator', fieldType: 'scalar',
              options: [
                  {value: '수협은행', label: '수협은행'},
                  {value: '하나증권', label: '하나증권'},
                  {value: '수협은행(연급저축)', label: '수협은행(연급저축)'},
                  {value: '하이자산운용', label: '하이자산운용'},
                  {value: 'KCGI자산운용', label: 'KCGI자산운용'},
                  {value: 'BNK자산운용', label: 'BNK자산운용'},
                  {value: '한국투신운용', label: '한국투신운용'},
                  {value: '푸르덴셜자산운용', label: '푸르덴셜자산운용'},
                  {value: '삼성자산운용', label: '삼성자산운용'},
                  {value: '우리자산운용', label: '우리자산운용'},
                  {value: '교보악사자산운용', label: '교보악사자산운용'},
                  {value: '신영자산운용', label: '신영자산운용'},
                  {value: '신한자산운용', label: '신한자산운용'},
                  {value: '맥쿼리투자신탁운용', label: '맥쿼리투자신탁운용'},
                  {value: '한화자산운용', label: '한화자산운용'},
                  {value: 'DB자산운용', label: 'DB자산운용'},
                  {value: '프랭클린템플턴투신', label: '프랭클린템플턴투신'},
                  {value: '유진자산운용', label: '유진자산운용'},
                  {value: 'KB자산운용', label: 'KB자산운용'},
                  {value: '맵스자산운용', label: '맵스자산운용'},
                  {value: 'HDC자산운용', label: 'HDC자산운용'},
                  {value: '이스트스프링자산운용', label: '이스트스프링자산운용'},
                  {value: '슈로더투자신탁운용', label: '슈로더투자신탁운용'},
                  {value: '도이치자산운용', label: '도이치자산운용'},
                  {value: 'NH-Amundi자산운용', label: 'NH-Amundi자산운용'},
                  {value: '피델리티자산운용', label: '피델리티자산운용'},
                  {value: '미래에셋자산운용', label: '미래에셋자산운용'},
                  {value: '키움투자자산운용', label: '키움투자자산운용'},
                  {value: 'IBK자산운용', label: 'IBK자산운용'},
                  {value: '베어링자산운용', label: '베어링자산운용'},
                  {value: '마이다스에셋자산운용', label: '마이다스에셋자산운용'},
                  {value: '다올자산운용', label: '다올자산운용'},
                  {value: '유리자산운용', label: '유리자산운용'},
                  {value: '타임폴리오자산운용', label: '타임폴리오자산운용'},
                  {value: '트러스톤자산운용', label: '트러스톤자산운용'},
                  {value: 'VIP자산운용', label: 'VIP자산운용'},
                  {value: '한국투자벨류자산운용', label: '한국투자벨류자산운용'},
                  {value: 'AB자산운용', label: 'AB자산운용'},
                  {value: '에셋플러스자산운용(주)', label: '에셋플러스자산운용(주)'},
                  {value: '한국투자증권(사모운용)', label: '한국투자증권(사모운용)'},
                  {value: '하나금융투자(연금저축)', label: '하나금융투자(연금저축)'}
              ]
        },
        {
            id: 'grade', label: '위험등급', field: 'grade', fieldType: 'scalar',
            options: [
                {value: '매우높은위험(1등급)', label: '매우높은위험(1등급)'},
                {value: '높은위험(2등급)', label: '높은위험(2등급)'},
                {value: '다소높은위험(3등급)', label: '다소높은위험(3등급)'},
                {value: '보통위험(4등급)', label: '보통위험(4등급)'},
                {value: '낮은위험(5등급)', label: '낮은위험(5등급)'},
                {value: '매우낮은위험(6등급)', label: '매우낮은위험(6등급)'},
            ]
        },
    ];

    const chipSelections = Object.fromEntries(CHIP_GROUPS.map(g => [g.id, new Set(['__ALL__'])]));

    /* 칩 바 렌더 */
    function renderChipBar() {
        const root = document.getElementById('chipFilters');
        root.innerHTML = CHIP_GROUPS.map(g => `
                        <div class="Chip-group" data-group="${g.id}">
                          <div class="glabel">${g.label}</div>
                          <div class="Chip-row">
                            <button type="button"
                              class="Chip ${chipSelections[g.id].has('__ALL__') ? 'active' : ''}"
                              data-value="__ALL__">전체</button>
                            ${g.options.map(o => `
                              <button type="button"
                                class="Chip ${chipSelections[g.id].has(o.value) ? 'active' : ''}"
                                data-value="${o.value}">${o.label}</button>
                            `).join('')}
                          </div>
                        </div>
                      `).join('');

        // 이벤트 바인딩
        root.querySelectorAll('.Chip-group').forEach(groupEl => {
            const gid = groupEl.dataset.group;
            groupEl.querySelectorAll('.Chip').forEach(btn => {
                btn.addEventListener('click', () => {
                    const val = btn.dataset.value;
                    const set = chipSelections[gid];

                    if (val === '__ALL__') {
                        chipSelections[gid] = new Set(['__ALL__']);
                    } else {
                        set.delete('__ALL__');
                        if (set.has(val)) set.delete(val); else set.add(val);
                        if (set.size === 0) set.add('__ALL__');
                    }

                    renderChipBar();
                    page = 1;          // ★ 필터 바뀌면 1페이지
                    fetchProducts();   // ★ 서버에서 다시 조회
                });
            });
        });
    }

    /* ================= 서버 호출 & 렌더 ================= */

    // 칩 선택 → 쿼리 파라미터로
    function buildFilterParams() {
        const params = new URLSearchParams();
        for (const g of CHIP_GROUPS) {
            const set = chipSelections[g.id];
            if (!set || set.has('__ALL__')) continue;
            const values = Array.from(set);
            if (values.length) params.append(g.id, values.join(','));
        }
        // 키워드
        if (keyword && keyword.trim()) params.append('keyword', keyword.trim())
        return params;
    }

    // 로딩 표시
    function setLoading(on) {
        if (on) {
            container.innerHTML = `
                          <div style="padding:24px;text-align:center;color:#6b7280">불러오는 중...</div>
                        `;
        }
    }

    const keywordInput = document.getElementById('keywordInput');

    // 간단 디바운스 : 특정 시간 동안 여러 번 실행되는 함수를 마지막 한 번만 실행되게 만드는 함수
    function debounce(fn, wait = 250) {
        let t; // 타이머 ID 저장용 변수

        return (...args) => {
            clearTimeout(t); // 이전에 예약된 타이머 취소
            t = setTimeout(() => fn(...args), wait);
        };
    }

    // 검색 기능 구현 : 검색 한 번만 실행
    const onSearchChange = debounce(() => {
        keyword = keywordInput.value || "";
        page = 1;
        fetchProducts();
    }, 250);

    keywordInput.addEventListener('input', onSearchChange);

    // 엔터 눌러도 폼 제출 막고 즉시 검색
    keywordInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            onSearchChange.cancel?.(); // 선택
            keyword = keywordInput.value || "";
            page = 1;
            fetchProducts();
        }
    });

    // ★ 서버에서 목록 받아오기
    async function fetchProducts() {
        setLoading(true);

        const qs = new URLSearchParams({
            sort: sortKey,          // 예: 'join_internet' | 'rate_desc' | 'release_desc'
            page: String(page),
            pageSize: String(pageSize),
        });
        // 필터 추가
        const filters = buildFilterParams();
        filters.forEach((v, k) => qs.append(k, v));

        try {
            const res = await fetch(`/BNK/product/items?${qs.toString()}`, {method: 'GET'});
            console.log(qs.toString());
            if (!res.ok) throw new Error('Server Error');
            const data = await res.json(); // { items, total, page, pageSize }
            console.log(data);

            // 총 개수
            const total = data.totalElements ?? 0;
            const size = data.pageable.pageSize ?? pageSize;
            totalEl.textContent = total;

            // 렌더
            const items = Array.isArray(data.content) ? data.content : [];
            // console.log(items);
            container.innerHTML = (view === 'grid') ? renderGrid(items) : renderList(items);

            const totalPages = data.totalPages;
            renderPager(data);
        } catch (err) {
            console.error(err);
            container.innerHTML = `<div style="padding:24px;text-align:center;color:#ef4444">목록을 불러오지 못했습니다.</div>`;
            pager.innerHTML = '';
        }
    }

    /* 페이지네이션 */
    function renderPager(data) {
        const makeBtn = (label, p, disabled = false, active = false) => `
                        <button class="page-btn ${active ? 'active' : ''}" ${disabled ? 'disabled' : ''}
                          aria-label="페이지 ${label}" data-page="${p}">${label}</button>`;

        let html = '';
        html += makeBtn('〈', Math.max(1, page - 1), data.first, false);

        for (let i = 1; i <= data.totalPages; i++) {
            html += makeBtn(String(i), i, false, i === page);
        }

        html += makeBtn('〉', Math.min(data.totalPages, page + 1), data.last, false);
        pager.innerHTML = html;

        pager.querySelectorAll('.page-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const target = Number(e.currentTarget.dataset.page);
                if (!isNaN(target) && target !== page) {
                    page = target;
                    fetchProducts(); // ★ 서버 재조회
                }
            });
        });
    }

    // ───────────────── 공통: 펀드 카드 템플릿 ─────────────────
    function renderFundCard(p) {
        // 여기서 p 객체 안에 있는 필드명을 실제 백엔드 명칭에 맞게 바꿔줘야 함

        // 실제 데이터가 오면 넣고, 없으면 하드코딩 사용하셈 ㅇㅇ

        const title      = p.pname || "하나IT코리아증권자투자신탁(제1호)[주식]ClassC-P2E";
        const riskType   = p.grade || "초고위험(높은위험)";
        const fundType   = p.type  || "주식형";
        const operator   = p.operator || "하나자산운용";

        const basePrice  = p.basePrice != null ? Number(p.basePrice).toLocaleString() : "2,033.56";
        const setupDate  = p.setupDate || "2007-05-03";
        const totalFee   = p.totalFee  != null ? `${Number(p.totalFee).toFixed(4)}%` : "1.1026%";

        // 수익률 하드코딩/실데이터 병합
        const ret1m  = formatReturn(p.ret1m  ??  5.86);
        const ret3m  = formatReturn(p.ret3m  ?? 45.25);
        const ret6m  = formatReturn(p.ret6m  ?? 76.21);
        const ret12m = formatReturn(p.ret12m ?? 75.92);
        const retTot = formatReturn(p.retTotal ?? 85.17);

        return `
      <article class="fund-card">
        <!-- 상단 타이틀 영역 -->
        <header class="fund-card-header">
          <h3 class="fund-card-title">${p.pname}</h3>
          <p class="fund-card-subtitle">
            초고위험(높은위험) | 주식형 | 하나자산운용
            <!--아래는 데이터가 들어갈 영역임-->
            ${p.grade || ''} ${p.type ? `| ${p.type}` : ''} ${p.operator ? `| ${p.operator}` : ''}
          </p>
          <div class="fund-card-meta">
            <span class="fund-meta-item">기준가 : ${basePrice}</span>
            <span class="fund-meta-item">설정일 : ${setupDate}</span>
            <span class="fund-meta-item">총 보수 : ${totalFee}</span>
          </div>
        </header>

        <!-- 수익률 박스들 -->
        <section class="fund-card-returns">
          <div class="fund-return-box">
            <div class="fund-return-value">${ret1m}</div>
            <div class="fund-return-label">(1개월)</div>
          </div>
          <div class="fund-return-box">
            <div class="fund-return-value">${ret3m}</div>
            <div class="fund-return-label">(3개월)</div>
          </div>
          <div class="fund-return-box">
            <div class="fund-return-value">${ret6m}</div>
            <div class="fund-return-label">(6개월)</div>
          </div>
          <div class="fund-return-box">
            <div class="fund-return-value">${ret12m}</div>
            <div class="fund-return-label">(12개월)</div>
          </div>
          <div class="fund-return-box">
            <div class="fund-return-value">${retTot}</div>
            <div class="fund-return-label">누적</div>
          </div>
        </section>

        <!-- 하단 버튼 영역(원하면 숨겨도 됨) -->
        <footer class="fund-card-footer">
          <!-- 비교담기 같은 버튼 쓰고 싶으면 여기에 -->
          <!-- <button type="button" class="btn btn-white">비교담기</button> -->
        </footer>
      </article>
    `;
    }

// 수익률 숫자 포맷터
    function formatReturn(v) {
        if (v == null || v === '') return '-';
        const num = Number(v);
        if (Number.isNaN(num)) return v; // 서버에서 이미 '5.86 %' 같이 주면 그대로
        return `${num.toFixed(2)} %`;
    }

    /* ================= 카드/리스트 템플릿: 기존 그대로 ================= */
    function renderGrid(items) {
        return `
      <div class="fund-grid">
        ${items.map(p => renderFundCard(p)).join('')}
      </div>
    `;
    }

    function renderList(items) {
        return `
      <div class="fund-list">
        ${items.map(p => renderFundCard(p)).join('')}
      </div>
    `;
    }

    /* ================= 이벤트 바인딩 ================= */
    document.getElementById('btnGrid').onclick = () => {
        view = 'grid';
        document.getElementById('btnGrid').classList.add('active');
        document.getElementById('btnList').classList.remove('active');
        fetchProducts();
    };
    document.getElementById('btnList').onclick = () => {
        view = 'list';
        document.getElementById('btnList').classList.add('active');
        document.getElementById('btnGrid').classList.remove('active');
        fetchProducts();
    };
    // 모든 추천 키워드 버튼 선택
    const keywordButtons = document.querySelectorAll('.keywords button');

    // 각 버튼 클릭 시 input에 해당 텍스트 입력
    keywordButtons.forEach(button => {
        button.addEventListener('click', () => {
            keywordInput.value = button.textContent;
            keywordInput.focus(); // 커서를 입력창으로 이동
        });
    });

    /* ================= 초기 로드 ================= */
    renderChipBar();
    fetchProducts();
});

// 페이지 이동
document.addEventListener("DOMContentLoaded", function () {
    const select = document.getElementById("selectFund");

    select.addEventListener("change", function () {
        const value = select.value;

        if (value === "fund") {
            window.location.href = "/BNK/product/fund/list";
        } else if (value === "TDF") {
            window.location.href = "/BNK/product/TDF/list";
        } else if (value === "ETF") {
            window.location.href = "/BNK/product/ETF/list";
        }
    });
});