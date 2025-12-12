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
    let sortKey = 'pbirate';   // 서버가 지원하도록 맞춰 주세요
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
            id: 'target', label: '제도', field: 'target', fieldType: 'scalar',
            options: [
                {value: 'DB', label: 'DB'},
                {value: 'DC', label: 'DC'},
                {value: 'IRP', label: 'IRP'},
            ]
        },
        {
            id: 'join', label: '만기', field: 'join', fieldType: 'array',
            options: [
                {value: '1년', label: '1년'},
                {value: '2년', label: '2년'},
                {value: '3년', label: '3년'},
                {value: '5년', label: '5년'},
            ]
        }
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

                    // ✅ 단일 선택: 클릭한 칩만 남기고 전부 제거
                    set.clear();
                    set.add(val);      // "__ALL__"도 하나의 값으로 취급

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
        const totalPages = data.totalPages;
        if (!totalPages || totalPages === 0) {
            pager.innerHTML = '';
            return;
        }

        const blockSize = 10;          // 한 번에 보여줄 페이지 수
        const current = page;          // 현재 페이지 (1부터 시작한다고 가정)
        const currentBlock = Math.floor((current - 1) / blockSize);
        const startPage = currentBlock * blockSize + 1;
        const endPage = Math.min(startPage + blockSize - 1, totalPages);

        const makeBtn = (label, p, disabled = false, active = false) => `
        <button class="page-btn ${active ? 'active' : ''}" 
                ${disabled ? 'disabled' : ''} 
                aria-label="페이지 ${label}" 
                data-page="${p}">${label}</button>`;

        let html = '';

        // 이전 페이지 버튼 (한 칸씩 이동)
        html += makeBtn('〈', Math.max(1, current - 1), data.first, false);

        // 현재 블록(startPage ~ endPage)만 표시
        for (let i = startPage; i <= endPage; i++) {
            html += makeBtn(String(i), i, false, i === current);
        }

        // 다음 페이지 버튼 (한 칸씩 이동)
        html += makeBtn('〉', Math.min(totalPages, current + 1), data.last, false);

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

    /* ================= 카드/리스트 템플릿: 기존 그대로 ================= */
    function renderGrid(items) {
        return `
                            <div class="grid">
                              ${items.map(p => `
                                <div class="card">
                                  <div class="name">${p.pname}</div>
                                  <div class="rate-big">${Number(p.pbirate).toFixed(2)}%</div>
                                  <div class="btns">
                                    <!--<button class="btn btn-white">자세히</button>-->
                                    <button class="btn btn-red" onclick="window.location.href='/BNK/product/view/${p.pid}'">신청하기</button>
                                  </div>
                                </div>
                              `).join('')}
                            </div>
                          `;
    }

    function renderList(items) {
        return `
                            <div class="list-wrap">
                              <div class="table">
                                <div class="thead">
                                  <div class="cell">상품명</div>
                                  <div class="cell">예정 적용금리</div>
                                  <div class="cell">신청</div>
                                </div>
                                ${items.map(p => `
                                  <div class="trow">
                                    <div class="cell name-col">
                                      <div>
                                        <div class="title">${p.pname}</div>
                                        <div class="new-prod"></div>
                                      </div>
                                    </div>
                                    <div class="cell rate-col">
                                      <span class="rate-base">${Number(p.pbirate).toFixed(2)}</span>
                                      <span class="rate-suffix">%</span>
                                    </div>
                                    <div class="cell btn-apply">
                                      <button class="btn btn-red" onclick="window.location.href='/BNK/product/view/${p.pid}'">신청하기</button>
                                    </div>
                                  </div>
                                `).join('')}
                              </div>
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
    // document.getElementById('sortSelect').onchange = (e) => {
    //     sortKey = e.target.value;  // 'join_internet' | 'rate_desc' | 'release_desc' 등
    //     page = 1;
    //     fetchProducts();
    // };
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