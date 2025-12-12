/*
    날짜 : 2025.11.20.
    이름 : 강민철
    내용 : product_insert_info.html JS 작성
 */

import {validateFirstAmt} from "/BNK/js/product/init_pjnfee.js";

document.addEventListener('DOMContentLoaded', async function () {
    /*======== 스탭퍼 스크립트 ========*/
    let currentStep = 1;                 // 1~5
    const totalSteps = 5;
    const state = {};                    // 모든 단계의 입력값을 여기에 저장(필요 시)
    let accPinValue = '';                // step5: 출금계좌 비밀번호 4자리

    /* 유효성 검사 정규표현식 */
    const reName = /^[가-힣]{2,10}$/;
    const reHp = /^01(?:0|1|[6-9])-(?:\d{4})-\d{4}$/;

    const pages = [...document.querySelectorAll('.step-page')];
    const steps = [...document.querySelectorAll('#wizardSteps .step')];
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');

    /* 유효성 검사 훅: 단계별로 통과하면 true 반환 */
    const validators = {
        async 1() {
            // 필수 입력 검증
            const form1 = document.getElementById('customerForm');
            const name = form1.name;
            const brthdt = form1.brthdt;
            const natcd = form1.natcd;
            const taxyr = form1.taxyr;
            const enlnm = form1.enlnm;
            const enfnm = form1.enfnm;
            const phone = form1.phone;
            const zipcd = form1.zipcd;
            const addr1 = form1.addr1;
            let checkValid = [false, null];
            const checkNGo = (input, comment1, id, regEx = null, comment2 = null) => {
                const span = document.getElementById(id);
                if (Array.isArray(input)) {
                    for (const inputElement of input) {
                        if (inputElement.value.trim() === "") {
                            span.innerText = comment1;
                            checkValid[0] = false;
                            if (checkValid[1] === null)
                                checkValid[1] = inputElement;
                            break;
                        } else
                            checkValid[0] = true;
                    }
                } else {
                    if (input.value.trim() === "") {
                        input.focus();
                        span.innerText = comment1;
                        checkValid[0] = false;
                        if (checkValid[1] === null)
                            checkValid[1] = input;
                    } else if (regEx !== null) {
                        if (!input.value.match(regEx)) {
                            span.innerText = comment2;
                            checkValid[0] = false;
                            if (checkValid[1] === null)
                                checkValid[1] = input;
                        }
                    } else
                        checkValid[0] = true;
                }
            }

            checkNGo(name, '성명을 입력해주세요.', 'name-comment', reName, '이름이 유효하지 않습니다.');
            checkNGo(brthdt, '생년월일을 입력해주세요.', 'brthdt-comment');
            checkNGo(natcd, '국적을 선택해주세요.', 'natcd-comment');
            checkNGo(taxyr, '귀속년도를 선택해주세요.', 'taxyr-comment');
            checkNGo([enlnm, enfnm], '영문이름을 입력해주세요.', 'ennm-comment');
            checkNGo(phone, '전화번호를 입력해주세요.', 'phone-comment', reHp, '전화번호가 유효하지 않습니다.');
            checkNGo([zipcd, addr1], '우편번호와 주소를 입력해주세요.', 'addr-comment');
            if (checkValid[0]) {
                await submitSlfcert();
            } else {
                checkValid[1].focus();
                return false;
            }
        },
        2() {
            // 예: 모든 약관 체크 확인
            // const ok = [...document.querySelectorAll('[name="agree"]:checked')].length >= 3;
            // if(!ok){ alert('모든 약관에 동의해주세요.'); return false; }
            console.log('validators[2] work check');
            const section = document.querySelector('#page2 .accept-terms');
            const items = [...section.querySelectorAll('.terms-list .terms-item')];
            const links = items.map(i => i.querySelector('a.icon-btn')).filter(Boolean);
            const ok = links.every(a => a.classList.contains('downloaded'));
            if (!ok) {
                alert('상품설명서 및 약관을 모두 다운로드(또는 열람)해주세요.');
                return false;
            }
            const esnInfo = $('#esn-info').checked;
            const termsConfirm = $('#terms-confirm').checked;
            if (!(esnInfo && termsConfirm)) {
                alert('필수 안내사항과 상품 설명 및 약관을 모두 읽고 동의해주세요.');
                return false;
            }
            // if (input.value === '' || !input.checkVisibility()) {
            //     alert('약관 및 상품설명서 수령방법을 선택, 입력해주세요.');
            //     return false;
            // }
            return true;
        },
        3() {
            const requiredChecks = [
                '#int-rates-confirm',
                '#pay-date-confirm',
                '#calc-basis-confirm',
                '#rates-note-confirm',
                '#disadvantages-confirm',
                '#p-i-limit-confirm'
            ].map(sel => $(sel));

            const areAllChecked = () => requiredChecks.every(chk => chk.checked);

            if (!areAllChecked()) {
                const firstUnchecked = requiredChecks.find(chk => !chk.checked);
                if (firstUnchecked) {
                    alert('모든 중요사항을 확인 후 체크해주세요.');
                    firstUnchecked.scrollIntoView({behavior: "smooth", block: "center"});
                    firstUnchecked.focus();
                }
                return false;
            }
            return true;
        },
        4() {
            if (!validateFirstAmt())
                return false;
            const accSelector = $('select[aria-label="출금계좌번호"]');
            const ok = accSelector.value !== '계좌를 선택해 주세요';
            if (!ok) {
                alert('출금계좌를 선택해 주세요');
                return false;
            }
            return validateFirstAmt();
        },
        async 5() {
            // 1) 출금계좌 선택 여부 확인 (4단계에서 선택한 계좌)
            const select = document.querySelector('select[aria-label="출금계좌번호"]');
            if (!select || select.value === '계좌를 선택해 주세요') {
                alert('출금계좌를 먼저 선택해 주세요.');
                return false;
            }

            // 2) 비밀번호 4자리 입력 여부 확인
            if (!accPinValue || accPinValue.length !== 4) {
                alert('출금계좌 비밀번호 4자리를 입력해 주세요.');
                const firstPin = document.querySelector('#accPin input.pin');
                if (firstPin) firstPin.focus();
                return false;
            }

            // 3) (선택) 실제 계좌 비밀번호 검증 API 연동
            // TODO: 계좌 비밀번호 검증이 필요하면 아래 주석을 참고해서 실제 API에 맞게 수정
            try {
                const res = await fetch('/BNK/api/account/verify-pin', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        pacc: select.value,   // 출금계좌번호
                        pin: accPinValue,     // 입력한 비밀번호 4자리
                        type: state.productInfo.pelgbl // 제도구분
                    })
                });
                console.log('pacc:', select.value, ' pin:', accPinValue);

                if (!res.ok) throw new Error('비밀번호 검증 요청 실패');

                const data = await res.json();  // 예: { valid: true/false }
                console.log('data:', data);
                if (!data) {
                    alert('출금계좌 비밀번호가 일치하지 않습니다. 다시 입력해 주세요.');
                    return false;
                }
            } catch (e) {
                console.error(e);
                alert('출금계좌 비밀번호 확인 중 오류가 발생했습니다.');
                return false;
            }
            console.log('검증 모두 통과');
            // 여기까지 통과하면 step5 통과
            return true;
        } // 제출 단계라면 서버 전송 등 처리
    };

    /* ============== step1 본인확인서 존재 여부 확인, 초기화면 설정 ============== */
    await (async function chkFATCAExist() {
        const wizard = document.getElementById('wizard');
        const mid = wizard.dataset.mid;
        try {
            const res = await fetch(`/BNK/api/slfcert/${mid}`, {method: 'HEAD'});
            if (res.ok) {
                wizard.setAttribute('data-has-info', 'true');
                showStep(2)
            } else if (res.status === 404) {
                wizard.setAttribute('data-has-info', 'false');
                showStep(1);
            }
        } catch (e) {
            console.error(e.message);
        }
    })();

    /* ============== step1 유효성 검사 ============== */
    const form1 = document.getElementById('customerForm');
    const name = form1.name;
    const brthdt = form1.brthdt;
    const natcd = form1.natcd;
    const taxyr = form1.taxyr;
    const enlnm = form1.enlnm;
    const enfnm = form1.enfnm;
    const phone = form1.phone;
    const zipcd = form1.zipcd;
    const addr1 = form1.addr1;

    const validComment = (input, comment1, spanId, regEx = null, comment2 = null) => {
        input.addEventListener('focusout', function () {
            const span = document.getElementById(spanId);
            if (input.value === null || input.value.trim() === "") {
                span.innerText = comment1;
            } else if (regEx !== null) {
                if (!input.value.match(regEx))
                    span.innerText = comment2;
            } else
                span.innerText = "";
        });
    }
    validComment(name, '성명을 입력해주세요.', 'name-comment', reName, '성명이 유효하지 않습니다.');
    validComment(brthdt, '생년월일을 선택해주세요.', 'brthdt-comment');
    validComment(natcd, '국적을 선택해주세요.', 'natcd-comment');
    validComment(taxyr, '귀속년도를 선택해주세요.', 'taxyr-comment');
    validComment(enlnm, '영문성명을 입력해주세요.', 'ennm-comment');
    validComment(enfnm, '영문성명을 입력해주세요.', 'ennm-comment');
    validComment(phone, '전화번호를 입력해주세요.', 'phone-comment', reHp, '전화번호가 유효하지 않습니다.');
    validComment(zipcd, '우편번호와 주소를 입력해주세요.', 'addr-comment');
    validComment(addr1, '우편번호와 주소를 입력해주세요.', 'addr-comment');
    form1.addr2.addEventListener('focusout', function () {
        const comment = document.getElementById('addr-comment');
        if (zipcd.value !== "" && addr1.value !== "")
            comment.innerText = "";
        else {
            comment.innerText = "우편번호와 주소를 입력해주세요.";
        }
    });

    /* 화면 전환 */
    function showStep(n) {
        currentStep = n;
        pages.forEach((el, i) => el.hidden = (i !== n - 1));

        steps.forEach((li, i) => {
            li.classList.remove('active', 'done');
            li.removeAttribute('aria-current');
            if (i < n - 1) li.classList.add('done');
            if (i === n - 1) {
                li.classList.add('active');
                li.setAttribute('aria-current', 'step');
            }
        });

        // 이전 버튼: step1에서는 숨김, 그 외엔 표시
        // 본인확인서 중복 제출 방지를 위해 page2에서도 숨김
        prevBtn.hidden = (n === 1) || (n === 2);

        nextBtn.textContent = (n === totalSteps) ? '신청' : '다음';

        // ✅ 5단계 진입 시 요약 카드 내용 채우기
        if (n === 5) {
            updateSummaryCard();
        }

        // 스크롤 보정
        document.querySelector('html').scrollIntoView({behavior: 'smooth', block: 'start'});
    }

    // ====================== step5 전송 payload 생성 ======================
    function collectStep5Payload() {
        // 1) 고객ID: wizard data-mid
        const wizard = document.getElementById('wizard');
        const cusid = wizard?.dataset.mid || '';

        // 2) 상품ID: url 변수
        const url = new URL(window.location.href);
        const parts = url.pathname.split('/');
        const pid = decodeURIComponent(parts[parts.length - 1]);

        // 3) 출금계좌번호: 4단계에서 선택한 select의 value (pacc)
        const accSelect = document.querySelector('#page4 select[aria-label="출금계좌번호"]');
        let pacc = '';
        if (accSelect && accSelect.value) {
            // initAccountAndFirstAmt에서 opt.value = acc.pacc 로 세팅하고 있으므로 그대로 사용
            pacc = accSelect.value;
        }

        // 4) 매수금액: firstAmt input의 숫자만 추출
        const firstAmtInput = document.getElementById('firstAmt');
        let firstAmt = 0;
        if (firstAmtInput && firstAmtInput.value) {
            const raw = firstAmtInput.value.replace(/[^\d]/g, '');
            if (raw) firstAmt = Number(raw);
        }

        // 5) 제도구분 / 금리: 상품 상세 응답에서 가져온다고 가정
        const productInfo = state.productInfo || {};

        // 제도구분(예: DC, DB, IRP…)  ← 필드명은 실제 DTO에 맞게 변경 필요
        // 추측입니다.
        const schemeType = productInfo.pelgbl || '';

        // 금리: 어떤 필드가 금리인지 명확히 보이지 않아서 몇 가지 후보를 두고 있음
        // 예: productInfo.intrate, productInfo.prate, productInfo.baseRate 등
        // 아래는 예시이므로 실제 필드명에 맞게 수정해야 함. (추측입니다.)
        const rate =
            productInfo.pbirate ??
            null;

        // 6) 계약일/만기일
        // 화면에 날짜 입력 필드가 없으므로 "신청 시각 = 계약일"로 잡는다고 가정
        // → 추측입니다. 계약일/만기일을 서버에서 계산한다면 여기서 굳이 보낼 필요는 없음.
        const today = new Date();
        const signdt = today.toISOString().slice(0, 19); // 'YYYY-MM-DD' 형식

        // 만기일 계산은 상품 정보에 계약기간 정보가 있어야 정확히 가능
        // 예: productInfo.periodMonth(개월), productInfo.periodDay(일수) 등이 있다고 가정
        // 아래는 "개월 수" 기준 예시 코드. 실제 필드명/로직에 맞게 수정 필요. (추측입니다.)
        let expdt = null;
        const yearPeriod = productInfo.prmthd.substring(0, productInfo.prmthd.indexOf("년"));
        const mdate = new Date(today);
        mdate.setFullYear(mdate.getFullYear() + Number(yearPeriod || 0));
        expdt = mdate.toISOString().slice(0, 19);

        // 서버에 전송할 payload (필드명은 백엔드 DTO/파라미터 이름에 맞춰 수정)
        return {
            // 고객ID
            "pcuid": cusid,

            // 상품ID
            "pcpid": pid,

            // 계좌 비밀번호
            "pcnapw": accPinValue,

            // 계좌번호
            "pacc": pacc,

            // 제도구분
            "type": schemeType,

            // 매수금액
            "pbalance": firstAmt,

            // 계약일
            "pnew": signdt,

            // 만기일
            "pend": expdt,

            // 금리
            "pcwtpi": rate
        };
    }

    /* 다음/제출 */
    nextBtn.addEventListener('click', async () => {
        // 현재 단계 저장/검증
        const validator = validators[currentStep];
        const ok = validator ? await validator() : true; // 없는 검증은 통과

        // 검증 실패하면 바로 중단
        if (!ok) return;

        // 마지막(step5)이면 서버로 전송
        if (currentStep === totalSteps) {
            // step5에서 모은 값들
            const payload = collectStep5Payload();
            console.log('step5 payload:', payload);

            try {
                const res = await fetch('/BNK/api/product/buy', {   // ← 실제 API URL로 변경
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(payload)
                });

                if (!res.ok) {
                    // 서버에서 에러 메세지 내려주면 여기서 처리해도 됨
                    alert('신청 처리 중 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.');
                    return;
                }

                // 필요하다면 응답 body 활용
                const result = await res.json();
                console.log(result);
                if (!result) {
                    alert('신청에 실패했습니다. 입력 정보를 다시 확인해 주세요');
                    return;
                }

                // 정상 처리 후 완료 페이지로 이동
                window.location.href = `/BNK/product/subCmpl/list?pid=${payload.pcpid}`;
            } catch (e) {
                console.error(e);
                alert('신청 처리 중 통신 오류가 발생했습니다.');
            }
            return;
        }

        // 그 외 단계는 다음 step으로 이동
        showStep(currentStep + 1);
    });

    // 본인확인서 제출 함수
    async function submitSlfcert() {
        // 서버 제출 동작(fetch)
        const fd = new FormData(form1);
        fd.set('krres', form1.krres.checked ? 'Y' : 'N');
        fd.set('others', form1.others.checked ? 'Y' : 'N');
        fd.set('ftype', form1.natcd.value === 'US' ? 'W9' : 'W8');
        fd.set('sts', 'VALID');
        await fetch('/BNK/api/slfcert', {
            method: 'POST',
            body: fd
        }).then(res => {
            if (res.ok)
                return res.json();
            else if (res.status === 204)
                return null;
            else
                throw new Error(`${res.status} ${res.statusText}`);
        }).then(data => {
            console.log(data);
            alert('본인확인서(FATCA/CRS)가 등록되었습니다!');
            root.dataset.hasInfo = 'true';
            return true;
        }).catch(e => {
            console.error(e.message);
            alert('등록 중 오류가 발생했습니다.\n' + e.message);
            return false;
        });
    }

    // 취소: 모든 단계에서 항상 동작
    document.getElementById('cancelBtn').addEventListener('click', () => {
        const ok = confirm('작성을 취소하고 이전 화면으로 돌아갈까요?\n저장되지 않은 내용은 사라질 수 있어요.');
        if (!ok) return;

        // 원하는 취소 정책으로 변경 가능
        if (history.length > 1) history.back();
        else location.href = '/';   // 또는 원하는 경로
    });

    // 이전
    prevBtn.addEventListener('click', () => {
        if (currentStep > 1) {
            if (!(getHasInfo() && currentStep === 2)) showStep(currentStep - 1);
        }
    });


    /* 스텝 클릭으로 점프 이동(선택) */
    steps.forEach((li, idx) => {
        li.style.cursor = 'pointer';
        li.addEventListener('click', () => {
            // 완료했거나 바로 이전까지만 허용 등 정책 가능
            if (idx + 1 <= currentStep || idx + 1 === currentStep + 1) {
                // 본인확인서 미등록시에만 step1 이동 가능
                if (!(idx === 0)) {
                    const ok = validators[currentStep]();
                    // console.log('validators return : ' + ok);
                    if (ok) {
                        console.log('currentStep is ' + currentStep);
                        showStep(idx + 1);
                    }
                }
            }
        });
    });

    /* 본인확인서(FATCA/CRS) 존재 여부 확인 */
    const $ = (sel, root = document) => root.querySelector(sel);
    const root = $('#wizard');

    function getHasInfo() {
        if (root && root.dataset.hasInfo != null) {
            return String(root.dataset.hasInfo).toLowerCase() === 'true';
        }
        return false;
    }


    /*============== 약관 및 상품설명서 받기 스크립트 ================*/
    // const radios = document.querySelectorAll('input[name="receive"]');
    // const input = document.getElementById('contactInput');
    // const help = document.getElementById('contact-help');
    // const error = document.getElementById('contact-error');
    //
    // function switchMode(mode) {
    //     input.value = '';
    //     error.textContent = '';
    //     if (mode === 'sms') {
    //         input.type = 'tel';
    //         input.placeholder = "휴대폰 번호 (‘-’ 포함) 예) 010-1234-5678";
    //         input.setAttribute('inputmode', 'numeric');
    //         input.setAttribute('autocomplete', 'tel');
    //         input.setAttribute('pattern', '^01(?:0|1|[6-9])-(?:\\d{4})-\\d{4}$');
    //         help.textContent = "휴대폰 번호는 ‘-’를 넣어서 입력해 주세요.";
    //     } else {
    //         input.type = 'email';
    //         input.placeholder = "이메일 주소";
    //         input.removeAttribute('inputmode');
    //         input.setAttribute('autocomplete', 'email');
    //         input.removeAttribute('pattern');
    //         help.textContent = "정확한 이메일 주소를 입력해 주세요.";
    //     }
    // }
    //
    // radios.forEach(r => r.addEventListener('change', e => switchMode(e.target.value)));
    // switchMode(document.querySelector('input[name="receive"]:checked').value);
    //
    // // 간단한 실시간 유효성 안내
    // input.addEventListener('blur', () => {
    //     if (!input.value) {
    //         error.textContent = '';
    //         return;
    //     }
    //     if (!input.checkValidity()) {
    //         error.textContent = (input.type === 'tel')
    //             ? '휴대폰 번호 형식이 올바르지 않습니다.'
    //             : '이메일 형식이 올바르지 않습니다.';
    //     } else {
    //         error.textContent = '';
    //     }
    // });

    // 이 폼에서 엔터 제출 금지
    // const termsForm = document.querySelector('.get-terms form');
    //
    // // 1) 기본 submit 자체 막기
    // termsForm.addEventListener('submit', (e) => e.preventDefault());
    //
    // // 엔터 → 현재 포커스된 요소만 포커스 해제
    // termsForm.addEventListener('keydown', (e) => {
    //     if ((e.key === 'Enter' || e.keyCode === 13) && !e.isComposing) {
    //         e.preventDefault();
    //         e.stopPropagation();
    //         const el = document.activeElement;
    //         if (el && typeof el.blur === 'function') el.blur();
    //     }
    // });

    // // (선택) 모바일 키보드 힌트만 ‘완료’로 바꾸기
    // input.setAttribute('enterkeyhint', 'done');


    /* ================= 상품설명서 및 약관 다운로드 표시 스크립트 ===================*/
    // 신규가입(2단계) 약관 다운로드 완료 표시
    (function initTermsDownload() {
        const section = document.querySelector('#page2 .accept-terms');
        if (!section) return;

        const titleWrap = section.querySelector('.terms-title');
        const items = [...section.querySelectorAll('.terms-list .terms-item')];
        const links = items.map(i => i.querySelector('a.icon-btn')).filter(Boolean);

        // 전역 state 재사용 (스텝 이동시 상태 유지)
        window.state = window.state || {};
        state.termsDownloaded = state.termsDownloaded || {};

        // 진행률 표시 (간단 텍스트)
        const progress = document.createElement('span');
        progress.setAttribute('aria-live', 'polite');
        progress.style.marginLeft = '8px';
        progress.style.fontSize = '12px';
        progress.style.color = '#6B7280';
        titleWrap.querySelector('h2')?.appendChild(progress);

        function updateProgress() {
            const done = links.filter(a => a.classList.contains('downloaded')).length;
            progress.textContent = `(${done}/${links.length} 완료)`;
        }

        function markDownloaded(a, key) {
            if (a.classList.contains('downloaded')) return;
            a.classList.add('downloaded');                // ← CSS 활용
            a.setAttribute('aria-label', (a.getAttribute('aria-label') || '다운로드') + ' - 완료');
            a.setAttribute('data-downloaded', 'true');
            state.termsDownloaded[key] = true;
            updateProgress();
        }

        // 초기 복원
        links.forEach((a, idx) => {
            const key = a.closest('.terms-item')?.querySelector('span')?.textContent?.trim() || `term-${idx + 1}`;
            if (state.termsDownloaded[key]) a.classList.add('downloaded');
        });
        updateProgress();

        // 이벤트 바인딩: 클릭, Enter, Space
        links.forEach((a, idx) => {
            const key = a.closest('.terms-item')?.querySelector('span')?.textContent?.trim() || `term-${idx + 1}`;

            a.addEventListener('click', () => markDownloaded(a, key));
            a.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' || e.key === ' ' || e.key === 'Spacebar') {
                    // a 요소는 기본 동작을 유지(다운로드), 완료만 표시
                    markDownloaded(a, key);
                }
            });
        });
    })();

    /*================== 3단계 중요내용 스크립트 =====================*/
    (() => {
        const requiredChecks = [
            '#int-rates-confirm',
            '#pay-date-confirm',
            '#calc-basis-confirm',
            '#rates-note-confirm',
            '#disadvantages-confirm',
            '#p-i-limit-confirm'
        ].map(sel => $(sel));

        const docAll = $('#doc-all-confirm');
        const docAllLabel = $('label[for="doc-all-confirm"]');

        // 처음에는 docAll 비활성화
        docAll.disabled = true;

        // 개별 체크 여부 검사
        const areAllChecked = () => requiredChecks.every(chk => chk.checked);

        // docAll 상태 갱신
        const updateDocAll = () => {
            if (areAllChecked()) {
                docAll.disabled = false;
                docAll.checked = true;
            } else {
                docAll.disabled = true;
                docAll.checked = false;
            }
        };

        // label 클릭 시 전체 체크 검사
        docAllLabel.addEventListener('click', (e) => {
            e.preventDefault();

            if (!areAllChecked()) {
                alert("위의 모든 사항을 확인 후 체크해주세요.");

                // UX 향상: 첫 번째 미체크 요소로 스크롤 이동
                const firstUnchecked = requiredChecks.find(chk => !chk.checked);
                if (firstUnchecked) {
                    firstUnchecked.scrollIntoView({behavior: "smooth", block: "center"});
                    firstUnchecked.focus();
                }

                return;
            }

            // 모든 항목 체크되어 있으면 docAll 체크 완료
            docAll.disabled = false;
            docAll.checked = true;
        });

        // 개별 체크박스가 변경될 때도 docAll 동기화
        requiredChecks.forEach(chk => {
            chk.addEventListener('change', updateDocAll);
        });
    })();


    /* ====================== 상품 정보 채우기 ====================== */
    const {initProdInfo} = await import('/BNK/js/product/init_prod_info.js');

    await (async () => {
        const url = new URL(window.location.href);
        const parts = url.pathname.split('/');
        const pid = decodeURIComponent(parts[parts.length - 1]);

        try {
            const res = await fetch(`/BNK/product/details/${pid}`, {method: "GET"});
            if (!res.ok) throw new Error('상품 정보를 가져오는 도중 문제 발생');

            const productInfo = await res.json();
            console.log(productInfo);
            initProdInfo(productInfo);

            // step5에서 쓰기 위한 정보 보관
            state.productInfo = productInfo;

            // 상품 유형으로 계좌 목록 조회
            const type = productInfo.pelgbl;
            const response = await fetch(`/BNK/api/account/${type}`, {method: "GET"});
            if (!response.ok) throw new Error('계좌 정보를 가져오는 도중 문제 발생');
            const accObject = await response.json();
            console.log(accObject);

            // 🔗 출금계좌 select + 잔액 + 최초불입금액 연동
            initAccountAndFirstAmt(accObject);
        } catch (e) {
            console.error(e.message);
        }
    })();

    /* ====================== 4단계 최초불입금액 UI + 계좌/비율 세팅 ====================== */

    /* 공통 숫자 포맷 */
    function formatNumber(v) {
        const n = String(v ?? '').replace(/[^\d]/g, '');
        if (!n) return '';
        return n.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    function setCurrencyInput(el) {
        if (!el) return;
        el.addEventListener('input', () => {
            const pos = el.selectionStart ?? el.value.length;
            const beforeLen = el.value.length;
            el.value = formatNumber(el.value);
            const afterLen = el.value.length;
            const diff = afterLen - beforeLen;
            const newPos = pos + diff;
            el.selectionStart = el.selectionEnd = newPos < 0 ? 0 : newPos;
        });
    }

    /* ---------- (1) 금액/목표금액 포맷 ---------- */
    const firstAmtInput = document.getElementById('firstAmt');   // 금액 직접 입력
    const goalInput = document.getElementById('goal');       // 목표금액(있으면)

    setCurrencyInput(firstAmtInput);
    setCurrencyInput(goalInput);

    /* ---------- (2) 최초불입금액 모드 전환(직접입력 / 비율입력) + 토글 버튼 ---------- */
    const firstAmtWrap = firstAmtInput ? firstAmtInput.closest('.unit-wrap') : null;
    const percentInput = document.getElementById('firstAmtPercent');
    const percentWrap = percentInput ? percentInput.closest('.unit-wrap') : null;
    const percentHelp = document.getElementById('firstAmtPercentHelp');

    // 🔐 비율 입력창 기본 설정 & 기존 제약 제거
    if (percentInput) {
        // 혹시 HTML에 maxlength="1" 같은 거 달려 있으면 제거
        percentInput.removeAttribute('maxlength');

        // 인라인 oninput="..." 같은 거 달려 있으면 제거
        percentInput.removeAttribute('oninput');
        percentInput.oninput = null;

        // 우리가 원하는 설정으로 다시 세팅
        percentInput.type = 'text';
        percentInput.inputMode = 'numeric';
        percentInput.pattern = '\\d*';  // 숫자만
        // 길이는 JS에서 0~100으로 클램프하니까 따로 maxLength 안 줘도 됨
    }

    let firstAmtMode = 'direct';  // 'direct' | 'percent'

// 토글 버튼 (직접입력 <-> 비율입력 전환용)
    const modeToggleBtn = document.createElement('button');
    modeToggleBtn.type = 'button';
    modeToggleBtn.style.marginTop = '4px';
    modeToggleBtn.style.background = 'none';
    modeToggleBtn.style.border = 'none';
    modeToggleBtn.style.padding = '0';
    modeToggleBtn.style.color = '#467abd';
    modeToggleBtn.style.cursor = 'pointer';
    modeToggleBtn.style.fontSize = '12px';

    function renderModeToggleText() {
        modeToggleBtn.textContent =
            firstAmtMode === 'direct'
                ? '잔액 비율(%)로 입력하기'
                : '금액으로 직접 입력하기';
    }

    function setFirstAmtMode(mode) {
        if (!firstAmtWrap || !percentWrap || !percentHelp) return;

        firstAmtMode = (mode === 'percent') ? 'percent' : 'direct';

        if (firstAmtMode === 'direct') {
            // 금액 입력만 보이기
            firstAmtWrap.style.display = '';
            percentWrap.style.display = 'none';
            percentHelp.style.display = 'none';

            // 비율 값/텍스트 초기화
            if (percentInput) percentInput.value = '';
            percentHelp.textContent = '비율을 입력하면 사용할 금액이 표시됩니다.';

            // 토글 버튼을 금액 입력 아래로
            firstAmtWrap.after(modeToggleBtn);
        } else {
            // 비율 입력만 보이기
            firstAmtWrap.style.display = 'none';
            percentWrap.style.display = '';
            percentHelp.style.display = '';

            // 토글 버튼을 비율 입력 아래로
            percentWrap.after(modeToggleBtn);
        }

        renderModeToggleText();
    }

// 초기 상태: 직접입력 모드
    if (firstAmtWrap && percentWrap && percentHelp) {
        setFirstAmtMode('direct');

        modeToggleBtn.addEventListener('click', () => {
            setFirstAmtMode(firstAmtMode === 'direct' ? 'percent' : 'direct');
        });
    }

    /* ---------- (3) 최초불입금액 칩 동작 ---------- */
    const chipsWrap = document.getElementById('firstAmtChips');

    if (chipsWrap && firstAmtInput) {
        chipsWrap.addEventListener('click', (e) => {
            const btn = e.target.closest('.Chip');
            if (!btn) return;

            // 칩 활성화 표시
            [...chipsWrap.querySelectorAll('.Chip')].forEach(c => c.classList.remove('active'));
            btn.classList.add('active');

            const won = btn.getAttribute('data-won');

            // 칩을 누르면 무조건 "직접입력" 모드로 전환
            setFirstAmtMode('direct');

            if (won) {
                // 정해진 금액 칩
                firstAmtInput.value = formatNumber(won);
                firstAmtInput.blur();
            } else {
                // "직접입력" 칩
                firstAmtInput.value = '';
                firstAmtInput.focus();
                firstAmtInput.select();
            }
        });
    }

    /* ---------- (4) 입력 포커스로도 모드 전환 ---------- */
    if (percentInput) {
        percentInput.addEventListener('focus', () => {
            setFirstAmtMode('percent');
        });
    }

    if (firstAmtInput) {
        firstAmtInput.addEventListener('focus', () => {
            setFirstAmtMode('direct');
        });
    }

    /* ---------- (5) 계좌/비율 세팅 + 금액 계산 (비율로 입력 시 사용할 금액 표시) ---------- */
    function initAccountAndFirstAmt(accData) {
        const select = document.querySelector('select[aria-label="출금계좌번호"]');
        const balanceHelp = document.getElementById('firstAmtBalanceHelp');
        const firstAmtInput = document.getElementById('firstAmt');
        const percentInput = document.getElementById('firstAmtPercent');
        const percentHelpText = document.getElementById('firstAmtPercentHelp');

        if (!select || !firstAmtInput) return;

        const accounts = Array.isArray(accData) ? accData : [accData];
        let currentBalance = 0;   // 선택된 계좌 잔액 (pbalance)

        const formatWon = (n) =>
            isNaN(n) ? '-' : Number(n).toLocaleString('ko-KR') + '원';

        // 1) 출금계좌 select 옵션 세팅
        select.innerHTML = '';
        const placeholder = document.createElement('option');
        placeholder.textContent = '계좌를 선택해 주세요';
        placeholder.disabled = true;
        placeholder.selected = true;
        select.appendChild(placeholder);

        accounts.forEach(acc => {
            if (!acc || !acc.pacc) return;
            const opt = document.createElement('option');
            opt.value = acc.pacc;
            opt.textContent = `부산은행 ${acc.pacc}`;
            select.appendChild(opt);
        });

        // 2) 비율을 기반으로 실제 사용할 금액 계산
        function applyPercent() {
            if (!percentInput) return;

            // 1) 입력값에서 숫자만 남기기
            let raw = (percentInput.value || '').replace(/[^\d]/g, '');

            // 아무 것도 없으면 초기화
            if (!raw) {
                firstAmtInput.value = '';
                if (percentHelpText) {
                    percentHelpText.textContent = '비율을 입력하면 사용할 금액이 표시됩니다.';
                }
                return;
            }

            // 2) 최대 3자리까지만 허용
            if (raw.length > 3) raw = raw.slice(0, 3);

            // 숫자로 변환
            let pct = Number(raw);

            // 3) 0 ~ 100 사이로 클램프
            if (pct > 100) pct = 100;
            if (pct < 0) pct = 0;

            // 🔁 입력창에 실제 보여줄 값 (여기서 한 번 더 세팅해 줘야 "안 보이는" 문제 방지)
            percentInput.value = pct ? String(pct) : '';

            // 계좌 잔액이 없거나, 비율이 0이면 금액 초기화
            if (!currentBalance || !pct) {
                firstAmtInput.value = '';
                if (percentHelpText) {
                    percentHelpText.textContent = '비율을 입력하면 사용할 금액이 표시됩니다.';
                }
                return;
            }

            // 4) 실제 사용할 금액 (원) 계산
            const amount = Math.floor(currentBalance * pct / 100);

            // 금액 input에 실제 금액 세팅 + 포맷 적용
            firstAmtInput.value = String(amount);
            firstAmtInput.dispatchEvent(new Event('input')); // setCurrencyInput로 3자리 콤마 적용

            // 안내 문구 갱신
            if (percentHelpText) {
                percentHelpText.textContent =
                    `잔액의 ${pct}% = ${formatWon(amount)} (최초불입금액에 자동 반영)`;
                percentHelpText.style.display = '';
            }
        }

        // 3) 계좌 선택 시 잔액 표시 + 비율 재계산
        select.addEventListener('change', () => {
            const pacc = select.value;
            const acc = accounts.find(a => a && a.pacc === pacc);
            currentBalance = acc ? Number(acc.pbalance || 0) : 0;

            if (balanceHelp) {
                if (currentBalance) {
                    balanceHelp.textContent =
                        `선택한 계좌 잔액: ${formatWon(currentBalance)}`;
                } else {
                    balanceHelp.textContent = '잔액 정보를 가져올 수 없습니다.';
                }
            }

            // 이미 비율이 입력돼 있으면, 계좌 바꾸자마자 다시 계산
            if (percentInput && percentInput.value) {
                applyPercent();
            }
        });

        // 4) 비율 입력 시마다 금액 계산
        if (percentInput) {
            percentInput.addEventListener('input', applyPercent);
            percentInput.addEventListener('change', applyPercent);
        }

        // 5) 사용자가 금액을 직접 바꾸면 비율 안내 초기화
        if (firstAmtInput && percentInput && percentHelpText) {
            firstAmtInput.addEventListener('input', () => {
                // applyPercent()에서 발생시킨 인위적인 input 이벤트는 무시
                if (!e.isTrusted) return;

                percentInput.value = '';
                percentHelpText.textContent = '비율을 입력하면 사용할 금액이 표시됩니다.';
            });
        }
    }

    //


    /*================== 5단계 pin 입력 스크립트 ==================*/

    // PIN 유틸
    function isSequentialOrRepeat(str) {
        if (str.length < 4) return false;
        // 반복(1111 등)
        if (/^(\d)\1{3}$/.test(str)) return true;
        // 오름차순 연속 0123, 4567, 6789
        if ('0123456789'.includes(str)) return true;
        // 내림차순 연속 9876, 3210
        if ('9876543210'.includes(str)) return true;
        return false;
    }

    // eye 아이콘 SVG
    function eyeSVG(open) {
        return open
            ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12Z"/><circle cx="12" cy="12" r="3"/></svg>'
            : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m2 2 20 20"/><path d="M10.58 10.58A3 3 0 0 0 12 15a3 3 0 0 0 2.42-4.42"/><path d="M16.88 16.88C15.6 17.6 14 18 12 18 5 18 1 12 1 12a20.3 20.3 0 0 1 6.21-5.31"/><path d="M17.94 6.06A10.9 10.9 0 0 1 23 12s-1.64 2.64-4.12 4.54"/></svg>';
    }

    // PIN 그룹 세팅: 비밀번호 마스킹 + 자동이동 + 붙여넣기, (옵션) 표시/숨김 토글
    function setupPin(groupId, onFilled, {withToggle = false} = {}) {
        const wrap = document.getElementById(groupId);
        const inputs = [...wrap.querySelectorAll('input.pin')];

        inputs.forEach(inp => {
            inp.maxLength = 1;
            inp.inputMode = 'numeric';
            inp.autocomplete = 'off';
            inp.pattern = '[0-9]*';
            inp.type = 'password';                    // 기본 마스킹
            inp.setAttribute('enterkeyhint', 'done');  // 모바일 Enter 라벨 "완료"
        });

        let showAll = false;    // 눈아이콘 전체 표시 상태
        let visible = -1;       // 마지막으로 입력된 칸(보이는 칸)

        const isFilled = () => inputs.every(i => i.value && i.value.length === 1);

        function applyMasking() {
            if (showAll) {
                inputs.forEach(i => i.type = 'text');
                return;
            }
            inputs.forEach((i, idx) => i.type = (idx === visible ? 'text' : 'password'));
        }

        // 입력/키동작
        inputs.forEach((inp, idx) => {
            inp.addEventListener('input', e => {
                e.target.value = e.target.value.replace(/\D/g, '').slice(0, 1);
                if (e.target.value) {
                    visible = idx;          // 방금 입력한 칸만 보이기
                    applyMasking();

                    // 다음 칸으로 포커스 이동(이 시점엔 직전 칸 그대로 보임)
                    if (inputs[idx + 1]) inputs[idx + 1].focus();

                    // 모두 채워졌으면 콜백
                    const v = inputs.map(i => i.value).join('');
                    if (v.length === inputs.length) onFilled?.(v);
                }
            });

            inp.addEventListener('keydown', e => {
                // 백스페이스로 이전 칸으로 이동 시: 이전 칸만 보이기
                if (e.key === 'Backspace' && !inp.value && inputs[idx - 1]) {
                    inputs[idx - 1].focus();
                    visible = idx - 1;
                    applyMasking();
                }
                // 값이 있는데 숫자키 누르면 덮어쓰기
                if (/^\d$/.test(e.key) && inp.value) {
                    inp.value = '';
                }
            });

            // 포커스 이동만으로는 마스킹 변화 없음
            inp.addEventListener('focus', () => { /* no-op */
            });

            // 그룹을 벗어나면 안전하게 모두 마스킹
            inp.addEventListener('blur', () => {
                setTimeout(() => {
                    if (!wrap.contains(document.activeElement) && !showAll) {
                        visible = -1;
                        applyMasking();
                    }
                }, 0);
            });
        });

        // 🔸 Enter 처리: 4자리 다 찬 상태에서 Enter → 제출 막고 포커스 해제
        wrap.addEventListener('keydown', e => {
            if (e.key === 'Enter' && isFilled()) {
                e.preventDefault();
                e.stopPropagation();
                visible = -1;       // 모두 마스킹
                applyMasking();
                // 포커스 완전 해제
                const active = document.activeElement;
                if (wrap.contains(active)) active.blur();

                // (권장) 폼의 암묵적 제출도 한 번 더 차단
                const form = wrap.closest('form');
                if (form) {
                    const onceBlock = ev => {
                        ev.preventDefault();
                    };
                    form.addEventListener('submit', onceBlock, {once: true});
                    // 0ms 뒤 자동 제거(이번 엔터로 인한 submit만 막음)
                    setTimeout(() => form.removeEventListener('submit', onceBlock), 0);
                }
            }
        });

        // 붙여넣기: 마지막 채워진 칸만 보이기
        wrap.addEventListener('paste', e => {
            const txt = (e.clipboardData.getData('text') || '').replace(/\D/g, '').slice(0, inputs.length);
            if (!txt) return;
            e.preventDefault();
            inputs.forEach((i, k) => i.value = txt[k] || '');
            visible = Math.min(txt.length, inputs.length) - 1;
            (inputs[visible] || inputs[0]).focus();
            applyMasking();
            if (txt.length === inputs.length) onFilled?.(txt);
        });

        // (옵션) 눈 아이콘 토글
        if (withToggle) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'pin-toggle';
            btn.setAttribute('aria-pressed', 'false');

            // 초기: 전체 숨김(showAll=false) → 감긴 눈 아이콘
            btn.innerHTML = eyeSVG(false);
            wrap.after(btn);

            btn.addEventListener('click', () => {
                showAll = !showAll;
                btn.setAttribute('aria-pressed', showAll ? 'true' : 'false');

                btn.innerHTML = eyeSVG(showAll);

                applyMasking();
            });
        }

        // 초기 상태
        visible = -1;
        applyMasking();

        return () => inputs.map(i => i.value).join('');
    }

    // 출금계좌 비밀번호 PIN (id="accPin")
    const accPinGet = setupPin('accPin', (v) => {
        // 입력된 4자리 값을 전역 상태에 저장
        accPinValue = v;

        const hint = document.getElementById('accPinHint');
        if (!hint) return;

        if (v && v.length === 4) {
            hint.textContent = '출금계좌 비밀번호 입력이 완료되었습니다.';
            hint.classList.remove('error');
        } else {
            hint.textContent = '출금계좌 비밀번호 4자리를 입력해주세요.';
            hint.classList.add('error');
        }
    });

    /* ====================== 5단계 요약 카드 채우기 ====================== */
    function updateSummaryCard() {
        // 1) 가입자명: 1단계 입력값 우선, 없으면 4단계 값
        const nameInput1 = document.querySelector('#customerForm input[name="name"]');
        const nameInput4 = document.querySelector('#page4 input[name="mname"]');
        const userName =
            (nameInput1 && nameInput1.value.trim()) ||
            (nameInput4 && nameInput4.value.trim()) ||
            '';

        // 2) 최초불입금(매수금액): 4단계 firstAmt input 값 사용
        const firstAmtInput = document.getElementById('firstAmt');
        let firstAmtText = '';
        if (firstAmtInput && firstAmtInput.value.trim()) {
            // 숫자만 추출해서 다시 포맷
            const raw = firstAmtInput.value.replace(/[^\d]/g, '');
            if (raw) {
                const num = Number(raw);
                firstAmtText = num.toLocaleString('ko-KR') + '원';
            }
        }

        // 3) 상품명: 4단계 input → 없으면 2단계 제목
        const pnameInput = document.querySelector('#page4 input[name="pname"]');
        const pnameFromTitle = document.querySelector('#page2 .product-name');
        const productName =
            (pnameInput && pnameInput.value.trim()) ||
            (pnameFromTitle && pnameFromTitle.textContent.trim()) ||
            '';

        // 4) 출금계좌: 4단계 select에서 선택된 option 텍스트
        const accSelect = document.querySelector('#page4 select[aria-label="출금계좌번호"]');
        let accText = '';
        if (accSelect && accSelect.selectedIndex > 0) {
            accText = accSelect.options[accSelect.selectedIndex].textContent.trim();
        }

        // 5) 실제 요약 카드 DOM에 반영
        const summary = document.querySelector('#page5 .summary');
        if (!summary) return;

        const rows = summary.querySelectorAll('.srow');
        if (rows.length < 2) return;

        const row1Values = rows[0].querySelectorAll('.cell.value');
        const row2Values = rows[1].querySelectorAll('.cell.value');

        if (row1Values.length >= 2) {
            // 가입자명
            row1Values[0].textContent = userName || '-';
            // 최초불입금
            row1Values[1].textContent = firstAmtText || '-';
        }

        if (row2Values.length >= 2) {
            // 상품명
            row2Values[0].textContent = productName || '-';
            // 출금계좌
            row2Values[1].textContent = accText || '-';
        }
    }

});
