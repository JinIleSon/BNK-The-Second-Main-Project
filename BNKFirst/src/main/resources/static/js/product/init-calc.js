// /* ================== 0) 유틸 ================== */
// function fmtKR(n) {
//     return n.toLocaleString('ko-KR');
// }
//
// /* ================== 1) 규칙 추출기 ================== */
// function parseRate(text) {
//     if (text == null) return null;
//     const t = String(text).trim();
//     if (!t || t === '-' || t.includes('무이자')) return 0;
//     const n = parseFloat(t.replace('%', '').replace(',', '.'));
//     return Number.isFinite(n) ? n : null;
// }
//
// function unitToMonths(s) {
//     const m = String(s).trim().match(/^(\d+)\s*(개월|년)$/);
//     if (!m) return null;
//     const v = Number(m[1]);
//     return m[2] === '년' ? v * 12 : v;
// }
//
// function makeMatcher(monthsText) {
//     const s = String(monthsText).replace(/\s+/g, ' ').trim();
//
//     // 1) 범위: A (이상|초과)? [구분자 또는 공백 생략 가능] B (미만|이하)?
//     // 예) "3개월이상 6개월미만", "3개월 이상 ~ 6개월 미만", "1년 초과 2년 이하"
//     let r = s.match(
//         /(\d+\s*(?:개월|년))\s*(이상|초과)?\s*(?:[~\-]\s*|\s+)?(\d+\s*(?:개월|년))\s*(미만|이하)?/
//     );
//     if (r) {
//         const a = unitToMonths(r[1]);           // 하한
//         const aOpen = r[2] === '초과';           // '초과'면 >
//         const b = unitToMonths(r[3]);           // 상한
//         // 상한 한정자가 없으면 기본을 '이하'로 볼 수도 있지만,
//         // 실제 표는 대부분 '미만/이하'를 붙이므로 기본은 폐구간으로 처리
//         const bOpen = r[4] === '미만';          // '미만'이면 <
//         return (m) => (aOpen ? m > a : m >= a) && (bOpen ? m < b : m <= b);
//     }
//
//     // 2) 단독 상한: "N개월 미만" / "N년 미만"
//     r = s.match(/^(\d+\s*(?:개월|년))\s*미만$/);
//     if (r) { const n = unitToMonths(r[1]); return (m) => m < n; }
//
//     // 3) 단독 하한: "N개월 초과" / "N년 초과"
//     r = s.match(/^(\d+\s*(?:개월|년))\s*초과$/);
//     if (r) { const n = unitToMonths(r[1]); return (m) => m > n; }
//
//     // 4) "N개월 이내" → m <= N
//     r = s.match(/^(\d+)\s*개월\s*이내$/);
//     if (r) { const n = Number(r[1]); return (m) => m <= n; }
//
//     // 5) "N개월 이상" / "N년 이상" → m >= N
//     r = s.match(/^(\d+\s*(?:개월|년))\s*이상$/);
//     if (r) { const n = unitToMonths(r[1]); return (m) => m >= n; }
//
//     // 6) "N개월 이하" / "N년 이하" → m <= N
//     r = s.match(/^(\d+\s*(?:개월|년))\s*이하$/);
//     if (r) { const n = unitToMonths(r[1]); return (m) => m <= n; }
//
//     // 7) 정확히 N개월 / N년
//     r = s.match(/^(\d+\s*(?:개월|년))$/);
//     if (r) { const n = unitToMonths(r[1]); return (m) => m === n; }
//
//     // 매칭 실패
//     return () => false;
// }
//
// function extractRules(tableRows, sectionLabel = '만기지급', rateColIndex = 2) {
//     const rules = [];
//     let inSection = false;
//     console.log(tableRows);
//     for (const [i, row] of tableRows.entries()) {
//         const cells = row.map(c => (c && c.content != null) ? String(c.content).trim() : '');
//         const hasLabel = cells.some(c => c.includes(sectionLabel));
//         if (hasLabel) inSection = true;
//         if (inSection && (cells[0].includes('만기후') || cells[0].includes('중도해지'))) break;
//         if (!inSection) continue;
//
//         const monthsIdx = hasLabel ? 1 : 0;
//         const monthsText = cells[monthsIdx];
//         const rateText = cells[rateColIndex];
//         if (!monthsText) continue;
//         const rate = parseRate(rateText);
//         if (rate == null) continue;
//
//         rules.push({label: monthsText, match: makeMatcher(monthsText), rate});
//         if (i === 0) rateColIndex -= 1;
//     }
//     return rules;
// }
//
// function findRateByMonths(rules, months) {
//     const hit = rules.find(r => r.match(months));
//     return hit ? hit.rate : null;
// }
//
// /* ================== 2) UI 렌더/계산 ================== */
// let RULES = []; // 전역 보관
//
// /* 표시 업데이트 */
// function updateRateBig(ratePct) {
//     const el = document.getElementById('rateBig');
//     if (el) el.textContent = (ratePct ?? 0).toFixed(2) + '%';
// }
//
// /* 계산기: input 값(개월)로 바로 계산 */
// function recalc(dirMax) {
//     const amount = Math.max(0, Number(document.getElementById('amount').value || 0));
//     let months = Number(document.getElementById('period').value);
//
//     if (!Number.isFinite(months) || months <= 0) {
//         months = 0; // 방어
//     }
//
//     const maxRatePct = findRateByMonths(RULES, months) + dirMax ?? 0;
//     updateRateBig(maxRatePct);
//
//     const r = maxRatePct / 100;
//     const interest = Math.floor(amount * r * (months / 12)); // 단리
//     const total = amount + interest;
//
//     document.getElementById('sumInt').textContent = fmtKR(interest) + '원';
//     document.getElementById('sumAmt').textContent = fmtKR(total) + '원';
// }
//
// // 라벨에서 '상한 개월수'를 뽑아내기 (미만이면 -1, 이하이면 그대로)
// function upperBoundMonths(label) {
//     const s = String(label).replace(/\s+/g, ' ').trim();
//
//     // 범위: A (이상|초과)? [구분자 생략 가능] B (미만|이하)?
//     let r = s.match(/(\d+\s*(?:개월|년))\s*(이상|초과)?\s*(?:[~\-]\s*|\s+)?(\d+\s*(?:개월|년))\s*(미만|이하)?/);
//     if (r) {
//         const upper = unitToMonths(r[3]);              // B
//         const open  = r[4] === '미만';                 // '미만'이면 열린 경계
//         return open ? upper - 1 : upper;               // 미만 → B-1, 이하 → B
//     }
//
//     // 단독 상한
//     r = s.match(/^(\d+\s*(?:개월|년))\s*이하$/);     // N개월 이하
//     if (r) return unitToMonths(r[1]);
//     r = s.match(/^(\d+)\s*개월\s*이내$/);            // N개월 이내
//     if (r) return Number(r[1]);
//
//     // 정확히 N개월/년
//     r = s.match(/^(\d+\s*(?:개월|년))$/);
//     if (r) return unitToMonths(r[1]);
//
//     // 하한만 있는 경우(이상/초과)는 상한 불명 → NaN 반환
//     // r = s.match(/^(\d+\s*(?:개월|년))\s*(이상|초과)$/); if (r) return NaN;
//
//     return NaN;
// }
//
// // 규칙 배열에서 '유한한 상한'들만 모아서 max 계산
// function maxMonthsFromRules(rules) {
//     const candidates = rules
//         .map(r => upperBoundMonths(r.label))
//         .filter(v => Number.isFinite(v) && v > 0);
//     return candidates.length ? Math.max(...candidates) : 0;
// }
//
// // "3개월이상 6개월미만" → 3
// // "12개월 초과 ~ 24개월 이하" → 13
// // "N개월 이상" → N,  "N개월 초과" → N+1
// // "N개월 이하/이내/미만" → 하한 없음으로 보고 1
// // "36개월" → 36
// function lowerBoundMonths(label) {
//     const s = String(label).replace(/\s+/g, ' ').trim();
//
//     // 범위: A (이상|초과)? [구분자 생략 가능] B (미만|이하)?
//     let r = s.match(/(\d+\s*(?:개월|년))\s*(이상|초과)?\s*(?:[~\-]\s*|\s+)?(\d+\s*(?:개월|년))\s*(미만|이하)?/);
//     if (r) {
//         const lower = unitToMonths(r[1]);
//         const open  = r[2] === '초과';       // '초과'면 열린 경계
//         return open ? lower + 1 : lower;     // 초과 → +1, 이상 → 그대로
//     }
//
//     // 단독 하한
//     r = s.match(/^(\d+\s*(?:개월|년))\s*이상$/);
//     if (r) return unitToMonths(r[1]);
//     r = s.match(/^(\d+\s*(?:개월|년))\s*초과$/);
//     if (r) return unitToMonths(r[1]) + 1;
//
//     // 단독 상한(하한 없음) → 1로 간주
//     if (/이하$|이내$|미만$/.test(s)) return 1;
//
//     // 정확히 N개월/년
//     r = s.match(/^(\d+\s*(?:개월|년))$/);
//     if (r) return unitToMonths(r[1]);
//
//     return NaN; // 인식 실패
// }
//
// function minMonthsFromRules(rules) {
//     const candidates = rules
//         .map(r => lowerBoundMonths(r.label))
//         .filter(v => Number.isFinite(v) && v > 0);
//     // 하한이 하나도 없으면 기본 1개월
//     return candidates.length ? Math.min(...candidates) : 1;
// }
//
// /* ================== 3) 공개 API ================== */
// export function initCalcFromRateTable(rateTable, dirMax) {
//     // 문자열로 올 수도 있음
//     if (!Array.isArray(rateTable)) {
//         if (typeof rateTable === 'string') {
//             try {
//                 rateTable = JSON.parse(rateTable);
//             } catch (e) {
//                 throw new TypeError('rate-rules: rateTable must be 2D array or JSON string.');
//             }
//         } else {
//             throw new TypeError('rate-rules: rateTable must be a 2D array.');
//         }
//     }
//
//     RULES = extractRules(rateTable, '만기지급', 2);
//     console.log(RULES);
//
//     const amountEl = document.getElementById('amount');
//     const periodEl = document.getElementById('period');
//
//     if (!periodEl) throw new Error('#period input element not found.');
//
//     const minM = minMonthsFromRules(RULES);
//     const maxM = maxMonthsFromRules(RULES);
//     periodEl.min = String(minM);
//     if (Number.isFinite(maxM) && maxM > 0) periodEl.max = String(maxM);
//
//     // 현재 값이 범위 밖이면 보정
//     let cur = Number(periodEl.value || 0);
//     if (!Number.isFinite(cur) || cur < minM) cur = minM;
//     if (Number.isFinite(maxM) && cur > maxM) cur = maxM;
//     periodEl.value = String(Math.floor(cur));
//
//     // 도움말 업데이트
//     const help = document.getElementById('perHelp');
//     if (help) help.textContent = `단위: 개월 (최소 ${minM}개월${maxM ? `, 최대 ${maxM}개월` : ''})`;
//
//     // 숫자 입력에 맞춰 이벤트 변경
//     amountEl?.addEventListener('input', recalc);
//     periodEl.addEventListener('input', () => {
//         const min = Number(periodEl.min || 1);
//         const max = Number(periodEl.max || 600);
//         let v = Number(periodEl.value || 0);
//         if (Number.isFinite(v)) {
//             if (v < min) v = min;
//             if (v > max) v = max;
//             v = Math.floor(v);
//             if (String(v) !== periodEl.value) periodEl.value = String(v);
//         }
//         recalc(dirMax);
//     });
//
//     recalc(dirMax);
// }
//
// /* ================== 4) 함수 테스트 ================== */
// // console.log( makeMatcher('3개월이상 6개월미만')(3) ); // true
// // console.log( makeMatcher('3개월이상 6개월미만')(5) ); // true
// // console.log( makeMatcher('3개월이상 6개월미만')(6) ); // false
// // console.log( makeMatcher('36개월')(36) );             // true




export function initCalcFromRateTable() {
    const amountInput = document.getElementById('amount');
    const rateBig = document.getElementById('rateBig');
    const periodEl = document.getElementById('period');
    const sumAmtEl = document.getElementById('sumAmt');
    const sumIntEl = document.getElementById('sumInt');

    if (!amountInput || !rateBig || !periodEl) return;

    // 고정값: 연이율(%), 예치기간(개월)
    const annualRate = parseFloat(rateBig.dataset.rate);      // 예: 3.5
    const months = parseInt(periodEl.dataset.months, 10);     // 예: 12

    function formatWon(n) {
    if (isNaN(n)) return '-';
    return n.toLocaleString('ko-KR') + '원';
}

    function recalc() {
    let principal = Number(amountInput.value);

    // 최소/음수 방지
    if (!principal || principal < Number(amountInput.min || 0)) {
    sumAmtEl.textContent = '-';
    sumIntEl.textContent = '-';
    return;
}

    // 단리(세전) 계산: 원금 × 연이율 × (개월/12)
    const interest = Math.floor(
    principal * (annualRate / 100) * (months / 12)
    );

    const total = principal + interest;

    sumAmtEl.textContent = formatWon(total);
    sumIntEl.textContent = formatWon(interest);
}

    // 처음 로딩 시 1회 계산
    recalc();

    // 예치금액이 변경될 때마다 재계산
    amountInput.addEventListener('input', recalc);
    amountInput.addEventListener('change', recalc);
}