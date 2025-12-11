/*================== 4단계 최초불입금액 규칙 파싱 =====================*/

// 숫자 포맷
function formatNumber(v) {
    const n = String(v).replace(/[^\d]/g, '');
    if (!n) return '';
    return n.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// 현재 적용 중인 최초불입 규칙
let firstAmtRule = null;

// 한국어 금액 문자열(예: '1천원', '580만원', '3백만원', '12만5천원') → 숫자
function parseKoreanMoney(str) {
    if (!str) return null;
    let s = str.replace(/\s|[,]/g, '').replace(/원|제한없음|총적립한도.*$/g, '');

    let value = 0;

    // "12만5천" 케이스 먼저 처리
    const manMatch = s.match(/(\d+)만/);
    if (manMatch) {
        value += parseInt(manMatch[1], 10) * 10000;
        s = s.replace(/(\d+)만/, '');
    }

    const chunMatch = s.match(/(\d+)천/);
    if (chunMatch) {
        value += parseInt(chunMatch[1], 10) * 1000;
        s = s.replace(/(\d+)천/, '');
    }

    const baekManMatch = s.match(/(\d+)백만원/);
    if (baekManMatch) {
        value += parseInt(baekManMatch[1], 10) * 100 * 10000; // 1백만원 = 100 * 10,000
        s = s.replace(/(\d+)백만원/, '');
    }

    const manOnlyMatch = s.match(/(\d+)만원/);
    if (manOnlyMatch) {
        value += parseInt(manOnlyMatch[1], 10) * 10000;
        s = s.replace(/(\d+)만원/, '');
    }

    const baekWonMatch = s.match(/(\d+)백/);
    if (baekWonMatch && !/만원/.test(str)) {
        value += parseInt(baekWonMatch[1], 10) * 100; // 1백원 등
        s = s.replace(/(\d+)백/, '');
    }

    const restDigits = s.match(/\d+/);
    if (restDigits) {
        value += parseInt(restDigits[0], 10);
    }

    return value || null;
}

/**
 * 최초불입금액 조건 문자열 → 규칙 객체
 * 예시 입력:
 *  - "1천원~580만원"
 *  - "월 2만원~50만원"
 *  - "3백만원 이상(원 단위)"
 *  - "1천만원 이상 제한없음"
 *  - "0원"
 */
function parseFirstAmtRule(ruleRaw) {
    const text = (ruleRaw || '').trim();
    if (!text) {
        return {
            type: 'default',
            isMonthly: false,
            min: null,
            max: null,
            step: 1000,
            fixed: null,
            placeholder: '최초불입금액을 입력해 주세요.'
        };
    }

    const compact = text.replace(/\s+/g, '');
    const isMonthly = compact.startsWith('월');
    const isWonUnit = compact.includes('(원단위)') || compact.includes('(원단위');
    const unlimited = compact.includes('제한없음');

    // 0원 고정
    if (compact === '0원') {
        return {
            type: 'fixed',
            isMonthly,
            min: 0,
            max: 0,
            step: 1,
            fixed: 0,
            placeholder: '0원'
        };
    }

    // "월 12만5천원" 처럼 단일 금액
    const fixedMatch = compact.match(/월?(\d.*원)$/);
    if (fixedMatch && !compact.includes('~') && !compact.includes('이상')) {
        const val = parseKoreanMoney(fixedMatch[1]);
        return {
            type: 'fixed',
            isMonthly,
            min: val,
            max: val,
            step: isWonUnit ? 1 : 1000,
            fixed: val,
            placeholder: text
        };
    }

    let min = null;
    let max = null;

    // 범위: "A~B"
    if (compact.includes('~')) {
        const [left, right] = compact.split('~');
        min = parseKoreanMoney(left);
        max = parseKoreanMoney(right);
    } else {
        // "A이상", "A이상제한없음" 등
        const minMatch = compact.match(/(.+?)이상/);
        if (minMatch) {
            min = parseKoreanMoney(minMatch[1]);
        }
        if (!unlimited) {
            // 최대값이 명시된 경우가 있다면 여기서 추가 처리
            max = null; // 제한없음
        }
    }

    const step = isWonUnit ? 1 : 1000;

    return {
        type: unlimited ? 'min-only' : (max != null ? 'range' : 'min-only'),
        isMonthly,
        min,
        max: unlimited ? null : max,
        step,
        fixed: null,
        placeholder: text
    };
}

/**
 * 규칙을 UI에 적용
 *  - placeholder 변경
 *  - 칩 재구성
 *  - min/max/step을 data-*에 저장 (검증용)
 */
export function applyFirstAmtRule(ruleText) {
    firstAmtRule = parseFirstAmtRule(ruleText);

    const input = document.getElementById('firstAmt');
    const chipsWrap = document.getElementById('firstAmtChips');
    if (!input || !chipsWrap) return;

    // placeholder 갱신
    input.placeholder = firstAmtRule.placeholder || '최초불입금액을 입력해 주세요.';

    // 데이터 속성에 규칙 저장 (검증용)
    input.dataset.min = firstAmtRule.min != null ? String(firstAmtRule.min) : '';
    input.dataset.max = firstAmtRule.max != null ? String(firstAmtRule.max) : '';
    input.dataset.step = firstAmtRule.step != null ? String(firstAmtRule.step) : '';
    input.dataset.monthly = firstAmtRule.isMonthly ? 'true' : 'false';

    // 칩 다시 그리기
    chipsWrap.innerHTML = '';

    // 칩 값 만들기
    let chipValues = [];

    if (firstAmtRule.fixed != null) {
        chipValues = [firstAmtRule.fixed];
    } else if (firstAmtRule.min != null && firstAmtRule.max != null) {
        const min = firstAmtRule.min;
        const max = firstAmtRule.max;
        const step = firstAmtRule.step || 1000;

        const mid1 = Math.round((min * 2 + max) / 3 / step) * step;
        const mid2 = Math.round((min + max * 2) / 3 / step) * step;

        chipValues = [min, mid1, mid2, max];
        chipValues = [...new Set(chipValues.filter(v => v >= min && v <= max))];
    } else if (firstAmtRule.min != null) {
        const min = firstAmtRule.min;
        const step = firstAmtRule.step || 1000;
        chipValues = [min, min * 2, min * 5, min * 10].map(v => {
            return Math.round(v / step) * step;
        });
        chipValues = [...new Set(chipValues)];
    } else {
        // 규칙이 애매하면 기존 기본값 유지
        chipValues = [10000, 100000, 500000, 1000000];
    }

    // 칩 DOM 생성
    const frag = document.createDocumentFragment();
    chipValues.forEach((val, idx) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'Chip' + (idx === 0 ? ' active' : '');
        btn.dataset.won = String(val);

        const labelPrefix = firstAmtRule.isMonthly ? '월 ' : '';
        btn.textContent = labelPrefix + formatNumber(val) + '원';
        frag.appendChild(btn);
    });

    // 직접입력 칩 추가
    const directBtn = document.createElement('button');
    directBtn.type = 'button';
    directBtn.className = 'Chip';
    directBtn.dataset.won = '';
    directBtn.textContent = '직접입력';
    frag.appendChild(directBtn);

    chipsWrap.appendChild(frag);

    // 기본값 세팅
    if (firstAmtRule.fixed != null) {
        input.value = formatNumber(firstAmtRule.fixed);
        input.readOnly = true;
    } else {
        input.readOnly = false;
        input.value = '';
    }
}

/**
 * 최초불입금액 검증 (validators[4]에서 사용)
 */
export function validateFirstAmt() {
    const input = document.getElementById('firstAmt');
    if (!input) return true;

    const raw = input.value.replace(/[^\d]/g, '');
    const val = raw ? parseInt(raw, 10) : NaN;

    const min = input.dataset.min ? parseInt(input.dataset.min, 10) : null;
    const max = input.dataset.max ? parseInt(input.dataset.max, 10) : null;

    if (isNaN(val)) {
        alert('매수금액을 입력해 주세요.');
        input.focus();
        return false;
    }

    if (min != null && val < min) {
        alert(`매수금액은 최소 ${formatNumber(min)}원 이상이어야 합니다.`);
        input.focus();
        return false;
    }
    if (max != null && val > max) {
        alert(`매수금액은 최대 ${formatNumber(max)}원 이하여야 합니다.`);
        input.focus();
        return false;
    }

    // (원 단위 강제하고 싶으면 step 체크도 가능)
    const step = input.dataset.step ? parseInt(input.dataset.step, 10) : null;
    if (step && step > 1 && val % step !== 0) {
        alert(`매수금액은 ${formatNumber(step)}원 단위로 입력해 주세요.`);
        input.focus();
        return false;
    }

    return true;
}