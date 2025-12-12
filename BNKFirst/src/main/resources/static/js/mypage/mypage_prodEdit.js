let editListLoaded = false;
let currentSellSummary = {
    fundCount: 0,
    fundQty: 0,
    fundAmount: 0,
    tdCount: 0,
    tdQty: 0,
    tdAmount: 0,
    totalCount: 0,
    totalQty: 0,
    totalAmount: 0
};
let currentIrpAccount = null;

// ✅ 보유 상품 / IRP 잔액 요약용 전역 변수 추가
let currentHoldingTotal = 0;   // 보유 상품 평가금액 합계
let currentIrpBalance = 0;   // IRP 계좌의 매수 가능 금액(pbalance)

// ✅ 매수상품 합계 전역
let currentBuySummary = {
    fundCount: 0,
    fundQty: 0,
    fundAmount: 0,
    tdCount: 0,
    tdQty: 0,
    tdAmount: 0,
    totalCount: 0,
    totalQty: 0,
    totalAmount: 0
};

document.addEventListener('DOMContentLoaded', () => {
    setupTabs();
    loadEditList();
    loadIrpAccount();
    setupSellSummaryActions();   // 매도합계 버튼/모달 이벤트
    setupBuySummaryActions();    // ✅ 매수합계 버튼/모달 이벤트
});

/* ================== 탭 전환 ================== */

function setupTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabPanels = document.querySelectorAll('.tab-panel');

    if (!tabButtons.length || !tabPanels.length) {
        return;
    }

    // 실제로 탭을 활성화하는 함수
    const activateTab = (targetId) => {
        if (!targetId) return;

        // 버튼 활성화 토글
        tabButtons.forEach(btn => {
            const isTarget = btn.dataset.tabTarget === targetId;
            btn.classList.toggle('is-active', isTarget);
        });

        // 패널 표시/숨김을 display로 확실하게 제어
        tabPanels.forEach(panel => {
            if (panel.id === targetId) {
                panel.classList.add('is-active');
                panel.style.display = 'block';
            } else {
                panel.classList.remove('is-active');
                panel.style.display = 'none';
            }
        });
    };

    // 각 버튼에 클릭 이벤트
    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const targetId = btn.dataset.tabTarget; // "tab-sell", "tab-buy" 등
            activateTab(targetId);
        });
    });

    // 초기 상태: 첫 번째 탭 버튼 기준으로 한 번 활성화
    const firstBtn = tabButtons[0];
    if (firstBtn && firstBtn.dataset.tabTarget) {
        activateTab(firstBtn.dataset.tabTarget);
    }
}

/* ================== 서식 유틸 ================== */

function formatCurrency(value) {
    if (typeof value !== 'number') {
        value = Number(value || 0);
    }
    if (Number.isNaN(value)) value = 0;
    return value.toLocaleString('ko-KR');
}

function formatPercent(value) {
    if (typeof value !== 'number') {
        value = Number(value || 0);
    }
    if (Number.isNaN(value)) value = 0;
    // 필요하면 자리수 조정
    return value.toFixed(2);
}

function getTypeLabel(type) {
    if (!type) return '';
    const t = String(type).toUpperCase();
    if (t === 'FUND') return '펀드';
    if (t.endsWith('TD')) return '원리금보장';
    return t;
}

// 보유상품 / IRP 잔액 기준으로
// - 각 카드 비중(상품 평가금액 / 총자산)
// - 보유 상품 요약
// - 매수 가능 금액 요약
// 을 한 번에 다시 계산
function recalcSummaryAndRatios() {
    // 1) 보유 상품(매도 탭)의 전체 평가금액 합
    const sellCards = document.querySelectorAll('#tab-sell .sell-card');
    let holdingsTotal = 0;

    sellCards.forEach(card => {
        const bal = Number(card.dataset.balance || 0);
        if (!Number.isNaN(bal)) {
            holdingsTotal += bal;
        }
    });

    // 2) IRP 잔액 (매수 가능 금액) - 없으면 0
    let irpBalance = 0;
    if (currentIrpAccount && currentIrpAccount.pbalance != null) {
        const tmp = Number(currentIrpAccount.pbalance);
        irpBalance = Number.isNaN(tmp) ? 0 : tmp;
    }

    // ✅ 전역에도 반영
    currentHoldingTotal = holdingsTotal;
    currentIrpBalance = irpBalance;

    // 3) 총자산 = 보유 상품 평가금액 합 + IRP 잔액
    const totalAsset = holdingsTotal + irpBalance;

    // 4) 각 상품 비중(상품 평가금액 / 총자산) 재계산
    const allCards = document.querySelectorAll('.product-card'); // 매도 + 매수 카드 전체
    allCards.forEach(card => {
        const bal = Number(card.dataset.balance || 0);
        let ratio = 0;
        if (totalAsset > 0 && !Number.isNaN(bal)) {
            ratio = (bal / totalAsset) * 100;
        }

        // dataset 에 현재 비중 저장 (일부매도 비중 계산용)
        card.dataset.ratio = String(ratio);

        // 화면에 보이는 비중 텍스트 갱신
        const ratioDd = card.querySelector('.ratio-value');
        if (ratioDd) {
            ratioDd.textContent = `${formatPercent(ratio)}%`;
        }
    });

    // 5) 보유 상품 요약(매도 탭)
    const summarySellAmount = document.querySelector('#tab-sell .summary-item.highlight .summary-value');
    const summarySellRatio = document.querySelector('#tab-sell .summary-item:nth-child(2) .summary-value');
    const summaryTotalAsset = document.querySelector('#tab-sell .summary-item:nth-child(3) .summary-value');

    const holdingsRatio = (totalAsset > 0)
        ? (holdingsTotal / totalAsset) * 100
        : 0;

    if (summarySellAmount) {
        summarySellAmount.textContent = `${formatCurrency(holdingsTotal)}원`;
    }
    if (summarySellRatio) {
        summarySellRatio.textContent = `${formatPercent(holdingsRatio)}%`;
    }
    if (summaryTotalAsset) {
        summaryTotalAsset.textContent = `${formatCurrency(totalAsset)}원`;
    }

    // 6) 매수 가능 금액 요약(매수 탭)
    const buyAvailEl = document.querySelector('#tab-buy .summary-item.highlight .summary-value');
    const buyEvalEl = document.querySelector('#tab-buy .summary-item:nth-child(2) .summary-value');
    const buyRatioEl = document.querySelector('#tab-buy .summary-item:nth-child(3) .summary-value');

    if (buyAvailEl) {
        buyAvailEl.textContent = `${formatCurrency(irpBalance)}원`;
    }
    if (buyEvalEl) {
        buyEvalEl.textContent = `${formatCurrency(holdingsTotal)}원`;
    }
    if (buyRatioEl) {
        buyRatioEl.textContent = `${formatPercent(holdingsRatio)}%`;
    }
}

function parseInputNumber(input) {
    if (!input) return 0;
    const raw = input.value.replace(/,/g, '').trim();
    if (raw === '') return 0;
    const n = Number(raw);
    if (Number.isNaN(n)) return 0;
    return n;
}

// ================== 요약 패널(보유 상품 / 매수 가능 금액) 갱신 ==================

function updateSummaryPanels() {
    const holding = currentHoldingTotal || 0;   // 보유 상품 평가금액 합계
    const cash = currentIrpBalance || 0;   // IRP 매수 가능 금액
    const totalAsset = holding + cash;

    const investRatio = totalAsset > 0 ? (holding / totalAsset) * 100 : 0;

    // ----- 매도 탭: 보유 상품 요약 -----
    const sellTab = document.getElementById('tab-sell');
    if (sellTab) {
        const evalEl = sellTab.querySelector('.summary-item.highlight .summary-value');          // 평가금액 합계
        const ratioEl = sellTab.querySelector('.summary-item:nth-child(2) .summary-value');      // 비중 합계
        const assetEl = sellTab.querySelector('.summary-item:nth-child(3) .summary-value');      // 총자산

        if (evalEl) evalEl.textContent = `${formatCurrency(holding)}원`;
        if (ratioEl) ratioEl.textContent = `${formatPercent(investRatio)}%`;
        if (assetEl) assetEl.textContent = `${formatCurrency(totalAsset)}원`;
    }

    // ----- 매수 탭: 매수 가능 금액 요약 -----
    const buyTab = document.getElementById('tab-buy');
    if (buyTab) {
        const buyCashEl = buyTab.querySelector('.summary-item.highlight .summary-value');       // 매수 가능 금액
        const buyEvalEl = buyTab.querySelector('.summary-item:nth-child(2) .summary-value');    // 현재 평가금액 합계
        const buyRatioEl = buyTab.querySelector('.summary-item:nth-child(3) .summary-value');    // 현재 비중 합계

        if (buyCashEl) buyCashEl.textContent = `${formatCurrency(cash)}원`;
        if (buyEvalEl) buyEvalEl.textContent = `${formatCurrency(holding)}원`;
        if (buyRatioEl) buyRatioEl.textContent = `${formatPercent(investRatio)}%`;
    }
}

function computeSellAmount(card) {
    const balance = Number(card.dataset.balance || 0); // 해당 상품 평가금액(원)
    if (!balance || balance <= 0) return 0;

    const amountInput = card.querySelector('.sell-input-area .amount-input');
    const percentInput = card.querySelector('.sell-input-area .percent-input');
    const mode = card.dataset.sellMode || '';

    // 1) 전부매도 모드일 때만 전액 매도
    if (mode === 'FULL') {
        return balance;
    }

    // 2) PART(일부매도)가 아니면 아직 매도 조건이 없는 상태로 간주 → 0원
    if (mode !== 'PART') {
        return 0;
    }

    // 3) PART 모드일 때
    const amount = parseInputNumber(amountInput);   // 원 단위 입력
    const percent = parseInputNumber(percentInput);  // 운용비율 감소량 (퍼센트 포인트)

    let sellAmount = 0;

    // 3-1) 비중 입력이 있으면 : 현재 비중 내에서 운용비율을 줄이는 개념
    if (percent > 0) {
        const currentRatio = Number(card.dataset.ratio || 0); // 현재 비중(%)

        if (currentRatio > 0) {
            // 입력 비중이 현재 비중을 넘지 않도록 제한
            const safePercent = Math.min(percent, currentRatio);

            // 매도금액 = 평가금액 × (감소비중 / 현재비중)
            // 예) 현재 30%, 평가금액 3,000 → 5%p 줄이면 3,000 * (5 / 30) = 500
            sellAmount = Math.floor(balance * (safePercent / currentRatio));
        }
    }
    // 3-2) 비중 입력이 없고 금액만 입력되면 : 금액 기준 일부매도
    else if (amount > 0) {
        sellAmount = amount;
    }

    // PART 모드인데 비중/금액 둘 다 0 또는 공백이면 0원 처리
    if (sellAmount <= 0) return 0;

    // 🔒 전부매도 금액(= balance)을 절대 넘지 않도록 최종 상한 적용
    if (sellAmount > balance) {
        sellAmount = balance;
    }

    return sellAmount;
}

function computeBuyAmount(card) {
    if (!card) return 0;

    const amountInput  = card.querySelector('.buy-input-area .amount-input');
    const percentInput = card.querySelector('.buy-input-area .percent-input');

    const amount  = parseInputNumber(amountInput);   // 원 단위 매수 금액
    const percent = parseInputNumber(percentInput);  // 매수 비중 (%)

    let buyAmount = 0;

    // 총자산 = 보유 상품 평가금액 + IRP 매수 가능 금액
    const totalAsset = (currentHoldingTotal || 0) + (currentIrpBalance || 0);
    if (totalAsset <= 0) {
        // 총자산이 0이면 비중 기준 계산은 불가능 -> 금액 입력만 사용
        if (amount > 0) return amount;
        return 0;
    }

    // 1) 비중 입력이 있으면: "총자산의 X%" 만큼을 이 상품에 매수
    if (percent > 0) {
        let pct = percent;
        if (pct > 100) pct = 100;
        if (pct < 0)   pct = 0;

        buyAmount = Math.floor(totalAsset * (pct / 100));
    }
    // 2) 비중이 없고 금액만 입력되면, 금액 기준 매수
    else if (amount > 0) {
        buyAmount = amount;
    }

    if (buyAmount <= 0) return 0;

    // ⛔ 여기서는 per-card 상한은 두지 않음
    // 총합이 IRP 잔액을 넘는지는 openBuyModal / submitBuyOrder 쪽에서 체크

    return buyAmount;
}

function updateSellSummary() {
    const cards = document.querySelectorAll('.sell-card');

    let fundCount = 0;   // 투자상품 선택 건수(실제로 매도금액 > 0 인 상품 수)
    let fundQty   = 0;   // 투자상품 매도좌수 (지금은 건수와 동일하게 사용)
    let fundAmount = 0;  // 투자상품 매도금액 합계

    let tdCount   = 0;   // 원리금보장상품 선택 건수
    let tdQty     = 0;   // 원리금보장상품 매도좌수
    let tdAmount  = 0;   // 원리금보장상품 매도금액 합계

    cards.forEach(card => {
        const checkbox = card.querySelector('.prod-check');
        if (!checkbox || !checkbox.checked) {
            // 체크되지 않은 카드는 "선택한 매도상품"에서 제외
            return;
        }

        const sellAmt = computeSellAmount(card);
        const hasQty  = sellAmt > 0;

        // ✅ 금액/비중이 하나도 없으면(= sellAmt === 0) 아예 집계에서 제외
        if (!hasQty) {
            return;
        }

        const typeRaw = card.dataset.type || '';
        const type = typeRaw.toUpperCase();

        if (type === 'FUND') {
            fundCount += 1;
            fundQty   += 1;
            fundAmount += sellAmt;
        } else if (type.endsWith('TD')) {
            tdCount   += 1;
            tdQty     += 1;
            tdAmount  += sellAmt;
        } else {
            // 기타 타입은 일단 투자상품으로 취급
            fundCount += 1;
            fundQty   += 1;
            fundAmount += sellAmt;
        }
    });

    const totalCount  = fundCount + tdCount;
    const totalQty    = fundQty + tdQty;
    const totalAmount = fundAmount + tdAmount;

    // 전역 합계 상태 저장 (모달에서도 사용)
    currentSellSummary = {
        fundCount,
        fundQty,
        fundAmount,
        tdCount,
        tdQty,
        tdAmount,
        totalCount,
        totalQty,
        totalAmount
    };

    const elFundCount   = document.getElementById('sumFundCount');
    const elFundQty     = document.getElementById('sumFundQty');
    const elFundAmount  = document.getElementById('sumFundAmount');
    const elTdCount     = document.getElementById('sumTdCount');
    const elTdQty       = document.getElementById('sumTdQty');
    const elTdAmount    = document.getElementById('sumTdAmount');
    const elTotalCount  = document.getElementById('sumTotalCount');
    const elTotalQty    = document.getElementById('sumTotalQty');
    const elTotalAmount = document.getElementById('sumTotalAmount');

    if (elFundCount)   elFundCount.textContent   = `${fundCount}`;
    if (elFundQty)     elFundQty.textContent     = `${fundQty}`;
    if (elFundAmount)  elFundAmount.textContent  = `${formatCurrency(fundAmount)}원`;
    if (elTdCount)     elTdCount.textContent     = `${tdCount}`;
    if (elTdQty)       elTdQty.textContent       = `${tdQty}`;
    if (elTdAmount)    elTdAmount.textContent    = `${formatCurrency(tdAmount)}원`;
    if (elTotalCount)  elTotalCount.textContent  = `${totalCount}`;
    if (elTotalQty)    elTotalQty.textContent    = `${totalQty}`;
    if (elTotalAmount) elTotalAmount.textContent = `${formatCurrency(totalAmount)}원`;
}

function updateBuySummary() {
    const cards = document.querySelectorAll('.buy-card');

    let fundCount = 0;
    let fundQty = 0;
    let fundAmount = 0;

    let tdCount = 0;
    let tdQty = 0;
    let tdAmount = 0;

    cards.forEach(card => {
        const checkbox = card.querySelector('.prod-check');
        if (!checkbox || !checkbox.checked) return;

        const typeRaw = card.dataset.type || '';
        const type = typeRaw.toUpperCase();

        const buyAmt = computeBuyAmount(card);
        const hasQty = buyAmt > 0;

        if (type === 'FUND') {
            fundCount += 1;
            fundAmount += buyAmt;
            if (hasQty) fundQty += 1;
        } else if (type.endsWith('TD')) {
            tdCount += 1;
            tdAmount += buyAmt;
            if (hasQty) tdQty += 1;
        } else {
            // 기타 타입은 투자상품으로
            fundCount += 1;
            fundAmount += buyAmt;
            if (hasQty) fundQty += 1;
        }
    });

    const totalCount = fundCount + tdCount;
    const totalQty = fundQty + tdQty;
    const totalAmount = fundAmount + tdAmount;

    currentBuySummary = {
        fundCount,
        fundQty,
        fundAmount,
        tdCount,
        tdQty,
        tdAmount,
        totalCount,
        totalQty,
        totalAmount
    };

    const elFundCount = document.getElementById('sumBuyFundCount');
    const elFundQty = document.getElementById('sumBuyFundQty');
    const elFundAmount = document.getElementById('sumBuyFundAmount');
    const elTdCount = document.getElementById('sumBuyTdCount');
    const elTdQty = document.getElementById('sumBuyTdQty');
    const elTdAmount = document.getElementById('sumBuyTdAmount');
    const elTotalCount = document.getElementById('sumBuyTotalCount');
    const elTotalQty = document.getElementById('sumBuyTotalQty');
    const elTotalAmount = document.getElementById('sumBuyTotalAmount');

    if (elFundCount) elFundCount.textContent = `${fundCount}`;
    if (elFundQty) elFundQty.textContent = `${fundQty}`;
    if (elFundAmount) elFundAmount.textContent = `${formatCurrency(fundAmount)}원`;
    if (elTdCount) elTdCount.textContent = `${tdCount}`;
    if (elTdQty) elTdQty.textContent = `${tdQty}`;
    if (elTdAmount) elTdAmount.textContent = `${formatCurrency(tdAmount)}원`;
    if (elTotalCount) elTotalCount.textContent = `${totalCount}`;
    if (elTotalQty) elTotalQty.textContent = `${totalQty}`;
    if (elTotalAmount) elTotalAmount.textContent = `${formatCurrency(totalAmount)}원`;
}

async function loadIrpAccount() {
    try {
        const res = await fetch('/BNK/api/account/IRP', {
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        });

        if (!res.ok) {
            console.error('IRP 계좌 조회 실패', res.status);
            return;
        }

        const dto = await res.json();
        // 예: { pacc: '123-456-789012', pbalance: 1234567, ... }
        currentIrpAccount = dto;

        // IRP 정보까지 반영해서 전체 비중/요약 다시 계산
        recalcSummaryAndRatios();

    } catch (e) {
        console.error('IRP 계좌 조회 중 오류', e);
    }
}

function buildSellOrderPayload() {
    const cards = document.querySelectorAll('.sell-card');

    const productList = []; // [{pcpid, type, pbalance}, ...]
    const sellTypes = []; // ['FULL', 'PART', ...]
    let totalAmount = 0;

    cards.forEach(card => {
        const checkbox = card.querySelector('.prod-check');
        if (!checkbox || !checkbox.checked) {
            // 체크되지 않은 상품은 매도 대상 아님
            return;
        }

        const balance = Number(card.dataset.balance || 0) || 0;
        if (balance <= 0) return;

        // 전부매도 / 일부매도 모드
        const modeRaw = card.dataset.sellMode || '';
        const sellType = modeRaw.toUpperCase() === 'PART' ? 'PART' : 'FULL';

        // 공통 계산 함수로 실제 매도 금액 계산
        let sellAmount = computeSellAmount(card);
        if (!sellAmount || sellAmount <= 0) {
            // PART인데 값이 없거나, 무엇인가 잘못된 경우 → 전송 대상에서 제외
            return;
        }

        const type = (card.dataset.type || '').toUpperCase();
        const pcpid = card.dataset.productId || '';

        productList.push({
            pcpid: pcpid,
            type: type,
            pbalance: sellAmount   // ← 서버 DTO에서 pbalance로 받을 예정
        });

        sellTypes.push(sellType);
        totalAmount += sellAmount;
    });

    return {
        productList: productList,
        sellTypes: sellTypes,
        totalAmount: totalAmount
    };
}

function openSellModal() {
    // 매도할 상품이 없거나 금액이 0이면 막기
    if (!currentSellSummary || currentSellSummary.totalAmount <= 0 || currentSellSummary.totalQty <= 0) {
        alert('매도할 상품을 선택하고 금액을 입력해 주세요.');
        return;
    }

    const backdrop = document.getElementById('sellModalBackdrop');
    const countEl = document.getElementById('modalSellCount');
    const amtEl = document.getElementById('modalSellAmount');
    const pinInput = document.getElementById('sellPinInput');

    // 모달에서 고객이 다시 확인할 수 있도록
    // → 총 매도 상품 수, 총 매도 금액을 그대로 노출
    if (countEl) {
        countEl.textContent = `${currentSellSummary.totalQty}건`;
    }
    if (amtEl) {
        amtEl.textContent = `${formatCurrency(currentSellSummary.totalAmount)}원`;
    }

    if (pinInput) {
        pinInput.value = '';
    }

    if (backdrop) {
        backdrop.classList.add('is-open');
    }

    if (pinInput) {
        setTimeout(() => pinInput.focus(), 50);
    }
}

function closeSellModal() {
    const backdrop = document.getElementById('sellModalBackdrop');
    if (backdrop) {
        backdrop.classList.remove('is-open');
    }
}


// 실제 매도 요청
async function submitSellOrder() {
    const pinInput = document.getElementById('sellPinInput');
    const pin = pinInput ? pinInput.value.trim() : '';

    // PIN 형식 체크 (숫자 4자리)
    if (!/^\d{4}$/.test(pin)) {
        alert('계좌 비밀번호 4자리를 입력해 주세요.');
        if (pinInput) {
            pinInput.focus();
        }
        return;
    }

    // 매도 payload 구성
    const payload = buildSellOrderPayload();
    if (
        !payload ||
        !Array.isArray(payload.productList) ||
        payload.productList.length === 0 ||
        payload.totalAmount <= 0
    ) {
        alert('매도할 상품을 선택하고 금액을 입력해 주세요.');
        return;
    }

    // IRP 계좌 정보 필수
    if (!currentIrpAccount || !currentIrpAccount.pacc) {
        alert('연금계좌 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.');
        return;
    }

    const pacc = currentIrpAccount.pacc;

    try {
        // 1) PIN 검증
        const verifyRes = await fetch('/BNK/api/account/verify-pin', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                pacc: pacc,
                pin: pin,
                type: "IRP"
            })
        });

        if (!verifyRes.ok) {
            alert('계좌 비밀번호 인증 중 문제가 발생했습니다.\n', verifyRes.status, ' ', verifyRes.statusText);
            return;
        }
        const verifyBool = await verifyRes.json();
        console.log('verifyBool', verifyBool);
        if (!verifyBool) {
            alert('계좌 비밀번호가 일치하지 않습니다. 다시 확인해 주세요.');
            if (pinInput) {
                pinInput.focus();
                pinInput.select && pinInput.select();
            }
            return;
        }

        // 2) 실제 매도 주문 요청
        const orderRequest = {
            pacc: pacc,
            totalAmount: payload.totalAmount,
            products: payload.productList, // [{pcpid, type, pbalance(=sellAmount)}, ...]
            sellTypes: payload.sellTypes    // ['FULL', 'PART', ...]
        };

        const orderRes = await fetch('/BNK/api/mypage/editSell', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(orderRequest)
        });

        if (!orderRes.ok) {
            console.error('매도 주문 실패', orderRes.status);
            alert('매도 과정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요');
            return;
        }

        alert('상품 변경이 완료되었습니다.');

        // 모달 닫기
        if (typeof closeSellModal === 'function') {
            closeSellModal();
        }

        // 리스트를 최신 상태로 다시 로딩
        editListLoaded = false;
        await loadEditList();

        // ✅ 매도상품 합계 상태 및 화면 리셋
        currentSellSummary = {
            fundCount: 0,
            fundQty: 0,
            fundAmount: 0,
            tdCount: 0,
            tdQty: 0,
            tdAmount: 0,
            totalCount: 0,
            totalQty: 0,
            totalAmount: 0
        };
        updateSellSummary();

    } catch (e) {
        console.error('매도 처리 중 예외', e);
        alert('매도 과정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요');
    }
}

function setupSellSummaryActions() {
    const openBtn = document.querySelector('.btn-open-sell-modal');
    const cancelBtn = document.querySelector('.btn-cancel-sell');
    const modalCancelBtn = document.getElementById('sellModalCancelBtn');
    const modalOkBtn = document.getElementById('sellModalConfirmBtn');
    const pinInput = document.getElementById('sellPinInput');

    if (openBtn) {
        openBtn.addEventListener('click', openSellModal);
    }

    if (cancelBtn) {
        // 이전 페이지로 돌아가기
        cancelBtn.addEventListener('click', () => {
            history.back();
        });
    }

    if (modalCancelBtn) {
        modalCancelBtn.addEventListener('click', () => {
            closeSellModal();
        });
    }

    if (modalOkBtn) {
        modalOkBtn.addEventListener('click', () => {
            if (!pinInput) return;
            const pin = (pinInput.value || '').trim();

            if (!/^\d{4}$/.test(pin)) {
                alert('계좌 비밀번호 4자리를 정확히 입력해 주세요.');
                pinInput.focus();
                return;
            }

            submitSellOrder(pin);
        });
    }

    if (pinInput) {
        // 숫자만 허용, 4자리 제한
        pinInput.addEventListener('input', () => {
            pinInput.value = pinInput.value.replace(/\D/g, '').slice(0, 4);
        });
    }
}

/*========================================== 매수 유틸 함수 ======================================================*/
function buildBuyOrderPayload() {
    const cards = document.querySelectorAll('.buy-card');

    const productList = []; // [{pcpid, type, pbalance}, ...]
    let totalAmount = 0;

    cards.forEach(card => {
        const checkbox = card.querySelector('.prod-check');
        if (!checkbox || !checkbox.checked) return;

        let buyAmount = computeBuyAmount(card);
        if (!buyAmount || buyAmount <= 0) return;

        const type = (card.dataset.type || '').toUpperCase();
        const pcpid = card.dataset.productId || '';

        productList.push({
            pcpid: pcpid,
            type: type,
            pbalance: buyAmount   // ← 서버 DTO에서 pbalance로 받을 예정 (매수금액)
        });

        totalAmount += buyAmount;
    });

    return {
        productList,
        totalAmount
    };
}

function openBuyModal() {
    if (!currentBuySummary || currentBuySummary.totalAmount <= 0 || currentBuySummary.totalQty <= 0) {
        alert('매수할 상품을 선택하고 금액을 입력해 주세요.');
        return;
    }

    // 🔒 IRP 매수 가능 금액 초과 여부 체크
    if (currentIrpBalance > 0 && currentBuySummary.totalAmount > currentIrpBalance) {
        alert('매수 가능 금액을 초과했습니다.\n매수 금액을 조정해 주세요.');
        return;
    }

    const backdrop = document.getElementById('buyModalBackdrop');
    const countEl = document.getElementById('modalBuyCount');
    const amtEl = document.getElementById('modalBuyAmount');
    const pinInput = document.getElementById('buyPinInput');

    if (countEl) {
        countEl.textContent = `${currentBuySummary.totalQty}건`;
    }
    if (amtEl) {
        amtEl.textContent = `${formatCurrency(currentBuySummary.totalAmount)}원`;
    }

    if (pinInput) {
        pinInput.value = '';
    }

    if (backdrop) {
        backdrop.classList.add('is-open');
    }

    if (pinInput) {
        setTimeout(() => pinInput.focus(), 50);
    }
}

function closeBuyModal() {
    const backdrop = document.getElementById('buyModalBackdrop');
    if (backdrop) {
        backdrop.classList.remove('is-open');
    }
}

// 실제 매수 요청
async function submitBuyOrder() {
    const pinInput = document.getElementById('buyPinInput');
    const pin = pinInput ? pinInput.value.trim() : '';

    if (!/^\d{4}$/.test(pin)) {
        alert('계좌 비밀번호 4자리를 입력해 주세요.');
        if (pinInput) pinInput.focus();
        return;
    }

    const payload = buildBuyOrderPayload();
    if (!payload ||
        !Array.isArray(payload.productList) ||
        payload.productList.length === 0 ||
        payload.totalAmount <= 0) {
        alert('매수할 상품을 선택하고 금액을 입력해 주세요.');
        return;
    }

    if (!currentIrpAccount || !currentIrpAccount.pacc) {
        alert('연금계좌 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.');
        return;
    }

    // 한 번 더 IRP 한도 체크
    if (currentIrpBalance > 0 && payload.totalAmount > currentIrpBalance) {
        alert('매수 가능 금액을 초과했습니다.\n매수 금액을 조정해 주세요.');
        return;
    }

    const pacc = currentIrpAccount.pacc;

    try {
        // 1) PIN 검증
        const verifyRes = await fetch('/BNK/api/account/verify-pin', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                pacc: pacc,
                pin: pin,
                type: "IRP"
            })
        });

        if (!verifyRes.ok) {
            alert('계좌 비밀번호 인증 중 문제가 발생했습니다.\n', verifyRes.status, ' ', verifyRes.statusText);
            return;
        }
        const verifyBool = await verifyRes.json();
        console.log('verifyBool', verifyBool);
        if (!verifyBool) {
            alert('계좌 비밀번호가 일치하지 않습니다. 다시 확인해 주세요.');
            if (pinInput) {
                pinInput.focus();
                pinInput.select && pinInput.select();
            }
            return;
        }

        // 2) 실제 매수 주문 요청 (URL은 상황에 맞게 조정)
        const orderRequest = {
            pacc: pacc,
            totalAmount: payload.totalAmount,
            products: payload.productList
        };

        const orderRes = await fetch('/BNK/api/mypage/editBuy', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(orderRequest)
        });

        if (!orderRes.ok) {
            console.error('매수 주문 실패', orderRes.status);
            alert('매수 과정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요');
            return;
        }

        alert('상품 매수가 완료되었습니다.');

        closeBuyModal();

        // 리스트 & 요약 최신화
        editListLoaded = false;
        await loadEditList();     // 보유 상품 리스트 갱신
        await loadIrpAccount();   // IRP 잔액 갱신

        // ✅ 매수상품 합계 리셋
        currentBuySummary = {
            fundCount: 0,
            fundQty: 0,
            fundAmount: 0,
            tdCount: 0,
            tdQty: 0,
            tdAmount: 0,
            totalCount: 0,
            totalQty: 0,
            totalAmount: 0
        };
        updateBuySummary();

    } catch (e) {
        console.error('매수 처리 중 예외', e);
        alert('매수 과정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요');
    }
}

function setupBuySummaryActions() {
    const openBtn = document.querySelector('.btn-open-buy-modal');
    const cancelBtn = document.querySelector('.btn-cancel-buy-summary');
    const modalCancelBtn = document.getElementById('buyModalCancelBtn');
    const modalOkBtn = document.getElementById('buyModalConfirmBtn');
    const pinInput = document.getElementById('buyPinInput');

    if (openBtn) {
        openBtn.addEventListener('click', openBuyModal);
    }

    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            history.back();
        });
    }

    if (modalCancelBtn) {
        modalCancelBtn.addEventListener('click', () => {
            closeBuyModal();
        });
    }

    if (modalOkBtn) {
        modalOkBtn.addEventListener('click', () => {
            if (!pinInput) return;
            const pin = (pinInput.value || '').trim();

            if (!/^\d{4}$/.test(pin)) {
                alert('계좌 비밀번호 4자리를 정확히 입력해 주세요.');
                pinInput.focus();
                return;
            }

            submitBuyOrder();
        });
    }

    if (pinInput) {
        pinInput.addEventListener('input', () => {
            pinInput.value = pinInput.value.replace(/\D/g, '').slice(0, 4);
        });
    }
}

/* ================== 메인: 상품 리스트 로딩 ================== */

async function loadEditList() {
    // 이미 한 번 로딩했다면 다시는 실행하지 않음 (탭 전환 시 재호출 방지)
    if (editListLoaded) {
        return;
    }
    editListLoaded = true;

    const sellGrid = document.querySelector('#tab-sell .product-grid');
    const buyGrid = document.querySelector('#tab-buy .product-grid');

    if (!sellGrid || !buyGrid) {
        console.warn('product-grid 컨테이너를 찾지 못했습니다.');
        return;
    }

    try {
        const res = await fetch('/BNK/api/mypage/editList', {
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        });

        if (!res.ok) {
            console.error('editList 호출 실패', res.status);
            return;
        }

        const data = await res.json();

        if (!Array.isArray(data) || data.length === 0) {
            sellGrid.innerHTML = '<p>보유 중인 상품이 없습니다.</p>';
            buyGrid.innerHTML = '<p>매수 가능한 상품이 없습니다.</p>';

            // 데이터가 없을 때도 요약은 0으로 세팅
            recalcSummaryAndRatios();
            return;
        }

        // DTO → 화면에서 쓰기 편한 형태로 변환
        const items = data.map(it => {
            const type = it.TYPE ?? it.type;
            const isFund = String(type || '').toUpperCase() === 'FUND';

            const name = isFund
                ? (it.fname ?? it.fName ?? it.FNAME)
                : (it.pname ?? it.pName ?? it.productName);

            // ✅ 상품 ID는 pcpid 로 고정
            const productId = it.pcpid ?? it.PCPID ?? '';

            return {
                type,
                name,
                productId: String(productId || ''),
                balance: Number(it.pbalance ?? it.balance ?? 0),
                rate: Number(it.pcwtpi ?? it.rate ?? 0)
            };
        });

        const totalBalance = items.reduce(
            (sum, it) => sum + (Number.isNaN(it.balance) ? 0 : it.balance),
            0
        );

        // 기존 더미 카드들 제거
        sellGrid.innerHTML = '';
        buyGrid.innerHTML = '';

        // ===== 카드 생성 =====
        items.forEach(item => {
            // (초기 ratio 는 보유상품 기준으로 잡지만,
            //  실제 최종 비중/요약은 recalcSummaryAndRatios() 에서 다시 계산됨)
            const ratio = totalBalance > 0 ? (item.balance / totalBalance) * 100 : 0;

            const typeLabel = getTypeLabel(item.type);
            const isFund = String(item.type ?? '').toUpperCase() === 'FUND';

            // 펀드: 수익률 0%, TD: pcwtpi를 수익률로 사용
            const yieldValue = isFund ? 0 : item.rate;
            const yieldText = isFund ? '0.00%' : `${formatPercent(yieldValue)}%`;
            const yieldClass =
                yieldValue > 0 ? 'plus' :
                    yieldValue < 0 ? 'minus' : '';

            const safeName = item.name || '상품명 미지정';
            const subText = typeLabel ? `${typeLabel} 상품` : '';

            /* ---------- 매도(상품 변경) 카드 ---------- */
            const sellCard = document.createElement('article');
            sellCard.className = 'product-card sell-card';

            // payload 생성을 위해 필요한 데이터 심기
            sellCard.dataset.type = item.type || '';
            sellCard.dataset.productId = item.productId || '';
            sellCard.dataset.balance = String(item.balance ?? 0);

            sellCard.innerHTML = `
                <div class="card-top">
                    <div class="prod-left">
                        <div class="prod-icon">${typeLabel || '상품'}</div>
                        <div class="prod-title">
                            <div class="prod-name">${safeName}</div>
                            <div class="prod-sub">${subText}</div>
                        </div>
                    </div>
                    <div class="radio-wrap">
                        <input type="checkbox" class="prod-check">
                    </div>
                </div>

                <dl class="prod-meta">
                    <div class="meta-row">
                        <dt>평가금액</dt>
                        <dd>${formatCurrency(item.balance)}원</dd>
                    </div>
                    <div class="meta-row" data-field="ratio">
                        <dt>비중</dt>
                        <dd class="ratio-value">${formatPercent(ratio)}%</dd>
                    </div>
                    <div class="meta-row">
                        <dt>수익률</dt>
                        <dd class="rate ${yieldClass}">${yieldText}</dd>
                    </div>
                </dl>

                <div class="card-actions">
                    <button type="button" class="btn btn-sheen btn-pressable btn-full-sell">전부매도</button>
                    <button type="button" class="btn btn-main btn-partial-toggle">일부매도</button>
                </div>

                <div class="sell-input-area">
                    <div class="meta-row">
                        <dt>일부 매도금액</dt>
                        <dd>
                            <input type="text" class="amount-input" placeholder="0">
                            <span class="unit">원</span>
                        </dd>
                    </div>
                    <div class="meta-row">
                        <dt>일부 매도 비중</dt>
                        <dd>
                            <input type="text" class="percent-input" placeholder="0">
                            <span class="unit">%</span>
                        </dd>
                    </div>
                    <div class="card-actions">
                        <button type="button" class="btn btn-sheen btn-pressable btn-partial-cancel">취소</button>
                    </div>
                </div>
            `;
            sellGrid.appendChild(sellCard);

            /* ---------- 매수 카드 ---------- */
            const buyCard = document.createElement('article');
            buyCard.className = 'product-card buy-card';

            buyCard.dataset.type = item.type || '';
            buyCard.dataset.productId = item.productId || '';
            buyCard.dataset.balance = String(item.balance ?? 0);

            buyCard.innerHTML = `
                <div class="card-top">
                    <div class="prod-left">
                        <div class="prod-icon">${typeLabel || '상품'}</div>
                        <div class="prod-title">
                            <div class="prod-name">${safeName}</div>
                            <div class="prod-sub">${subText}</div>
                        </div>
                    </div>
                    <div class="radio-wrap">
                        <input type="checkbox" class="prod-check">
                    </div>
                </div>

                <dl class="prod-meta">
                    <div class="meta-row">
                        <dt>평가금액</dt>
                        <dd>${formatCurrency(item.balance)}원</dd>
                    </div>
                    <div class="meta-row" data-field="ratio">
                        <dt>비중</dt>
                        <dd class="ratio-value">${formatPercent(ratio)}%</dd>
                    </div>
                    <div class="meta-row">
                        <dt>수익률</dt>
                        <dd class="rate ${yieldClass}">${yieldText}</dd>
                    </div>
                </dl>

                <div class="card-actions">
                    <button type="button" class="btn btn-main btn-toggle-buy">매수하기</button>
                </div>

                <div class="buy-input-area">
                    <div class="meta-row">
                        <dt>매수 금액</dt>
                        <dd>
                            <input type="text" class="amount-input" placeholder="0">
                            <span class="unit">원</span>
                        </dd>
                    </div>
                    <div class="meta-row">
                        <dt>매수 비중</dt>
                        <dd>
                            <input type="text" class="percent-input" placeholder="0">
                            <span class="unit">%</span>
                        </dd>
                    </div>
                    <div class="card-actions">
                        <button type="button" class="btn btn-sheen btn-pressable btn-cancel-buy">취소</button>
                    </div>
                </div>
            `;
            buyGrid.appendChild(buyCard);
        });

        // 동적으로 생성한 카드에 이벤트 연결
        attachSellCardHandlers();
        attachBuyCardHandlers();

        // 보유상품/IRP 잔액 기반으로 비중 + 요약 다시 계산
        recalcSummaryAndRatios();

    } catch (err) {
        console.error('editList 호출 중 예외', err);
    }
}

/* ================== 카드별 토글 핸들러 ================== */

function attachSellCardHandlers() {
    const sellCards = document.querySelectorAll('.sell-card');

    sellCards.forEach(card => {
        const fullBtn = card.querySelector('.btn-full-sell');
        const partialBtn = card.querySelector('.btn-partial-toggle');
        const cancelBtn = card.querySelector('.btn-partial-cancel');
        const checkbox = card.querySelector('.prod-check');
        const amountInput = card.querySelector('.sell-input-area .amount-input');
        const percentInput = card.querySelector('.sell-input-area .percent-input');

        /* ---- 전부매도 버튼: 토글 (전부매도 ↔ 전부매도 취소) ---- */
        if (fullBtn) {
            fullBtn.addEventListener('click', () => {
                const mode = card.dataset.sellMode || '';

                // 이미 전부매도 상태면 → 전부매도 취소
                if (mode === 'FULL') {
                    card.dataset.sellMode = '';
                    if (checkbox) checkbox.checked = false;
                    if (amountInput) amountInput.value = '';
                    if (percentInput) percentInput.value = '';
                    card.classList.remove('is-part-open');
                    fullBtn.textContent = '전부매도';
                }
                // 전부매도 설정
                else {
                    card.dataset.sellMode = 'FULL';
                    if (amountInput) amountInput.value = '';
                    if (percentInput) percentInput.value = '';
                    card.classList.remove('is-part-open'); // 일부매도 영역은 접기
                    if (checkbox) checkbox.checked = true;
                    fullBtn.textContent = '전부매도 취소';
                }

                updateSellSummary();
            });
        }

        /* ---- 일부매도 버튼: 입력 영역 열기 + PART 모드 ---- */
        if (partialBtn) {
            partialBtn.addEventListener('click', () => {
                card.dataset.sellMode = 'PART';
                card.classList.add('is-part-open');
                if (checkbox) checkbox.checked = true;
                if (fullBtn) fullBtn.textContent = '전부매도'; // 전부매도 취소 상태였다면 복원
                updateSellSummary();
            });
        }

        /* ---- 일부매도 영역의 취소 버튼 ---- */
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                card.dataset.sellMode = '';
                card.classList.remove('is-part-open');
                if (amountInput) amountInput.value = '';
                if (percentInput) percentInput.value = '';
                if (checkbox) checkbox.checked = false;
                if (fullBtn) fullBtn.textContent = '전부매도';
                updateSellSummary();
            });
        }

        /* ---- 금액 입력 시: PART 모드 + 비중 값 지우기 + 전부매도 금액( balance )을 넘지 못하게 ---- */
        if (amountInput) {
            amountInput.addEventListener('input', () => {
                // 금액 입력하면 비중은 초기화
                if (percentInput && percentInput.value !== '') {
                    percentInput.value = '';
                }

                // 숫자만 허용 (천단위 구분자 같은 건 나중에 다시 넣어줌)
                let raw = amountInput.value.replace(/[^\d]/g, '');

                // 전부 지웠을 때
                if (raw === '') {
                    amountInput.value = '';
                    card.dataset.sellMode = '';
                    updateSellSummary();
                    return;
                }

                let n = Number(raw);
                if (Number.isNaN(n)) {
                    n = 0;
                }

                // 이 상품의 전부매도 금액 = 평가금액 (= balance)
                const balance = Number(card.dataset.balance || 0) || 0;

                // 전부매도 금액을 넘지 못하도록 clamp
                if (balance > 0 && n > balance) {
                    n = balance;
                }

                // 화면에는 천단위 콤마 붙여서 보여주기
                amountInput.value = n.toLocaleString('ko-KR');

                // 일부매도로 간주 + 체크박스 자동 체크
                if (n > 0) {
                    card.dataset.sellMode = 'PART';
                    if (checkbox) checkbox.checked = true;
                    if (fullBtn) fullBtn.textContent = '전부매도';
                } else {
                    card.dataset.sellMode = '';
                }

                updateSellSummary();
            });
        }

        /* ---- 비중 입력 시: PART 모드 + 금액 값 지우기 + 0. 같은 중간 상태 허용 ---- */
        if (percentInput) {
            percentInput.addEventListener('input', () => {
                // 비중 입력하면 금액은 초기화
                if (amountInput && amountInput.value !== '') {
                    amountInput.value = '';
                }

                let raw = percentInput.value;

                // 1) 숫자와 '.'만 허용
                raw = raw.replace(/[^0-9.]/g, '');

                // 2) 점 여러 개 입력 시 첫 번째 점만 남기기
                const firstDot = raw.indexOf('.');
                if (firstDot !== -1) {
                    const before = raw.slice(0, firstDot + 1);               // 점 포함 앞부분
                    const after = raw.slice(firstDot + 1).replace(/\./g, ''); // 나머지 점 제거
                    raw = before + after;
                }

                // 3) 소수 둘째 자리까지만 허용
                const dotIdx = raw.indexOf('.');
                if (dotIdx !== -1) {
                    const intPart = raw.slice(0, dotIdx);
                    const decPart = raw.slice(dotIdx + 1, dotIdx + 1 + 2); // 최대 2자리
                    raw = intPart + '.' + decPart;
                }

                percentInput.value = raw; // 여기까지는 "0.", "0.5" 그대로 허용

                // 4) 숫자로 해석 가능한 경우에만 현재 비중보다 큰지 체크해서 clamp
                const currentRatio = Number(card.dataset.ratio || 0) || 0;
                const pNum = parseFloat(raw);

                if (!Number.isNaN(pNum)) {
                    if (currentRatio > 0 && pNum > currentRatio) {
                        // 현재 비중을 초과하지 않도록 강제
                        percentInput.value = String(currentRatio);
                    }
                }

                // 값이 있으면 PART 모드 + 체크
                if (percentInput.value.trim() !== '') {
                    card.dataset.sellMode = 'PART';
                    if (checkbox) checkbox.checked = true;
                    if (fullBtn) fullBtn.textContent = '전부매도';
                } else {
                    card.dataset.sellMode = '';
                }

                updateSellSummary();
            });
        }

        /* ---- 체크박스 직접 조작 시 ---- */
        if (checkbox) {
            checkbox.addEventListener('change', () => {
                if (!checkbox.checked) {
                    // 선택 해제되면 모드/입력/버튼 상태 리셋
                    card.dataset.sellMode = '';
                    if (amountInput) amountInput.value = '';
                    if (percentInput) percentInput.value = '';
                    card.classList.remove('is-part-open');
                    if (fullBtn) fullBtn.textContent = '전부매도';
                }
                updateSellSummary();
            });
        }
    });
}

function attachBuyCardHandlers() {
    const buyCards = document.querySelectorAll('.buy-card');

    buyCards.forEach(card => {
        const toggleBtn = card.querySelector('.btn-toggle-buy');
        const cancelBtn = card.querySelector('.btn-cancel-buy');
        const checkbox = card.querySelector('.prod-check');
        const amountInput = card.querySelector('.buy-input-area .amount-input');
        const percentInput = card.querySelector('.buy-input-area .percent-input');

        // 공통: 카드 상태 리셋
        function resetCard() {
            card.classList.remove('is-buy-open');
            if (amountInput) amountInput.value = '';
            if (percentInput) percentInput.value = '';
            if (checkbox) checkbox.checked = false;
            if (toggleBtn) toggleBtn.textContent = '매수하기';
            updateBuySummary();
        }

        /* ---- 상단 매수하기 버튼: 토글 (매수하기 ↔ 매수 취소) ---- */
        if (toggleBtn) {
            toggleBtn.addEventListener('click', () => {
                const isOpen = card.classList.toggle('is-buy-open');

                if (isOpen) {
                    if (checkbox) checkbox.checked = true;
                    toggleBtn.textContent = '매수 취소';
                } else {
                    resetCard();
                }
            });
        }

        /* ---- 하단 입력영역의 취소 버튼 ---- */
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                resetCard();
            });
        }

        /* ---- 금액 입력: 숫자 + 천단위 포맷 + 비중 초기화 ---- */
        if (amountInput) {
            amountInput.addEventListener('input', () => {
                // 비중 입력값이 있으면 지우기
                if (percentInput && percentInput.value !== '') {
                    percentInput.value = '';
                }

                let raw = amountInput.value.replace(/[^\d]/g, '');

                if (raw === '') {
                    amountInput.value = '';
                    updateBuySummary();
                    return;
                }

                let n = Number(raw);
                if (Number.isNaN(n)) n = 0;

                // 단일 상품이 매수가능금액을 넘지 않도록
                if (currentIrpBalance > 0 && n > currentIrpBalance) {
                    n = currentIrpBalance;
                }

                amountInput.value = n.toLocaleString('ko-KR');

                if (n > 0) {
                    card.classList.add('is-buy-open');
                    if (checkbox) checkbox.checked = true;
                    if (toggleBtn) toggleBtn.textContent = '매수 취소';
                }

                updateBuySummary();
            });
        }

        /* ---- 비중 입력: 0~100, 소수 둘째 자리까지 + 금액 초기화 ---- */
        if (percentInput) {
            percentInput.addEventListener('input', () => {
                // 비중 입력하면 금액은 초기화
                if (amountInput && amountInput.value !== '') {
                    amountInput.value = '';
                }

                let raw = percentInput.value;

                // 1) 숫자와 '.'만 허용
                raw = raw.replace(/[^0-9.]/g, '');

                // 2) 점 여러 개 입력 시 첫 번째 점만 남기기
                const firstDot = raw.indexOf('.');
                if (firstDot !== -1) {
                    const before = raw.slice(0, firstDot + 1);                // 점 포함 앞부분
                    const after  = raw.slice(firstDot + 1).replace(/\./g, ''); // 나머지 점 제거
                    raw = before + after;
                }

                // 3) 소수 둘째 자리까지만 허용
                let decPart = '';
                const dotIdx = raw.indexOf('.');
                if (dotIdx !== -1) {
                    const intPart   = raw.slice(0, dotIdx);
                    const decPartRaw = raw.slice(dotIdx + 1);
                    decPart = decPartRaw.slice(0, 2);                         // 소수부 최대 2자리
                    raw = intPart + '.' + decPart;
                }

                // 4) 숫자로 해석 가능한 경우에만 0~100 범위로 제한
                const pNum = parseFloat(raw);
                if (!Number.isNaN(pNum)) {
                    let clamped = pNum;
                    if (clamped > 100) clamped = 100;
                    if (clamped < 0)   clamped = 0;

                    // ✅ 범위를 벗어난 경우에만 덮어쓰기
                    //    (예: 120 → 100, -1 → 0)
                    if (clamped !== pNum) {
                        raw = String(clamped);
                    }
                    // 범위 안(0~100)인 값들: 0, 0.0, 0.01, 10.25 등은 건드리지 않음
                }

                // 최종 값 반영
                percentInput.value = raw;

                // 값이 있으면 "매수 열림 + 체크" 상태로
                if (percentInput.value.trim() !== '') {
                    card.classList.add('is-buy-open');
                    if (checkbox) checkbox.checked = true;
                    if (toggleBtn) toggleBtn.textContent = '매수 취소';
                }

                updateBuySummary();
            });
        }

        /* ---- 체크박스 직접 조작 시 ---- */
        if (checkbox) {
            checkbox.addEventListener('change', () => {
                if (!checkbox.checked) {
                    resetCard();
                } else {
                    card.classList.add('is-buy-open');
                    if (toggleBtn) toggleBtn.textContent = '매수 취소';
                    updateBuySummary();
                }
            });
        }
    });
}

