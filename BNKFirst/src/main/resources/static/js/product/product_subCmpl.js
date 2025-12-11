document.addEventListener('DOMContentLoaded', async () => {

    // ★ 서버에서 목록 받아오기
    async function fetchProducts() {

        const mid = document.getElementById('script').dataset.mid;
        if (!mid) throw new Error("mid 없음");
        const pcpid = document.getElementById('script').dataset.pcpid;
        if (!pcpid) throw new Error("pcpid 없음");

        try {
            const res = await fetch(`/BNK/product/subCmpl?mid=${mid}&pcpid=${pcpid}`, {method: 'GET'});

            const cmplInfo = await res.json();
            console.log(cmplInfo);

            renderCmpl(cmplInfo);
        } catch (err) {
            console.error(err);
        }
    }

    function renderCmpl(cmplInfo) {

        const mname = document.getElementById('mname');
        const mphone = document.getElementById('mphone');
        const pname = document.getElementById('pname');
        const pnew = document.getElementById('pnew');
        const pend = document.getElementById('pend');
        const pccprd = document.getElementById('pccprd');
        const pcntcs = document.getElementById('pcntcs');
        const pacc = document.getElementById('pacc');
        const pcatapp = document.getElementById('pcatapp');
        const pcatdt = document.getElementById('pcatdt');
        const pcatac = document.getElementById('pcatac');
        const pccns = document.getElementById('pccns');
        const pwtpi = document.getElementById('pwtpi');
        const nowSpan1 = document.getElementById('getNowDateTimeV1');
        const nowSpan2 = document.getElementById('getNowDateTimeV2');
        const pbalance = document.querySelector('.money-list .li:first-child .v');
        const interestValue = document.querySelector('.money-list .li:nth-child(2) .v');
        const expectation = document.querySelector('.money-list .li:last-child .v');

        mname.innerText = cmplInfo.mname;

        // const [p1, p2, p3] = cmplInfo.mphone.split('-');
        // const p2Masked = '*'.repeat(p2.length);

        // const pMasked = `${p1}-${p2Masked}-${p3}`;

        // mphone.innerText = pMasked;

        pname.innerText = cmplInfo.pname;

        // pnew 날짜 포맷팅
        const formattedPnew = cmplInfo.pnew.slice(0, 10).replaceAll('-', '.');
        pnew.innerText = formattedPnew;
        console.log(formattedPnew);


        // pend 날짜 포맷팅
        const formattedPend = cmplInfo.pend.slice(0, 10).replaceAll('-', '.');
        pend.innerText = formattedPend;
        console.log(formattedPend);

        pccprd.innerText = cmplInfo.pend.slice(0,4) - cmplInfo.pnew.slice(0,4);
        // pcntcs.innerText = cmplInfo.pcntcs;
        const [a1, b1, c1] = cmplInfo.pacc.split('-');
        const bMask = '*'.repeat(b1.length);
        const cMask = '**' + c1.slice(2);

        const masked = `${a1}-${bMask}-${cMask}`;

        pacc.innerText = masked;

        // pcatapp.innerText = cmplInfo.pcatapp;

        // if (cmplInfo.pcatapp === 'true'){
        //     pcatapp.innerText = '신청완료';
        // }else{
        //     pcatapp.innerText = '미신청';
        // }

        // pcatdt.innerText = cmplInfo.pcatdt;

        // const [a2, b2, c2] = cmplInfo.pcatac.split('-');
        // const bMasked2 = '*'.repeat(b2.length);
        // const cMasked2 = '**' + c2.slice(2);

        // const masked2 = `${a2}-${bMasked2}-${cMasked2}`;

        // pcatac.innerText = masked2;

        // pccns.innerText = cmplInfo.pccns;
        pwtpi.innerText = cmplInfo.pcwtpi.toFixed(2) + '% (연 기준)';
        nowSpan1.innerText = getNowDateTimeV1();
        nowSpan2.innerText = getNowDateTimeV2();

        pbalance.innerText = cmplInfo.pbalance.toLocaleString('ko-KR') + '원';
        interestValue.innerText = (Math.floor(cmplInfo.pbalance * cmplInfo.pcwtpi / 100)).toLocaleString('ko-KR') + '원';
        expectation.innerText = (Math.floor(cmplInfo.pbalance * (cmplInfo.pcwtpi+100) / 100)).toLocaleString('ko-KR') + '원';
    }

    function getNowDateTimeV1() {
        const now = new Date();

        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');

        const hh = String(now.getHours()).padStart(2, '0');
        const mm = String(now.getMinutes()).padStart(2, '0');

        return `${y}.${m}.${d} ${hh}:${mm}`;
    }

    function getNowDateTimeV2() {
        const now = new Date();

        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');

        const hh = String(now.getHours()).padStart(2, '0');
        const mm = String(now.getMinutes()).padStart(2, '0');

        return `${y}${m}${d}${hh}${mm}`;
    }


    fetchProducts();
});
