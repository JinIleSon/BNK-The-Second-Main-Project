import {initCalcFromRateTable} from "/BNK/js/product/init-calc.js";

document.addEventListener('DOMContentLoaded', async () => {
    // 렌더링
    fetchProduct().then(data => {
        // console.log('check1');
        renderProduct(data);
        initCalcFromRateTable();
        // console.log('check2');
        try {
            // console.log(data.pirinfo);
            if (data.pterms !== null)
                renderTerms(data.pterms);
            // console.log('check3');
            if (data.pinfo !== null)
                renderIRInfo(data.pinfo);
            // console.log('pdirate: '+data.pdirate);
            // if (data.pdirate !== null) {
            //     const pdirate = JSON.parse(data.pdirate);
            //     renderDIInfo(pdirate);
            //     if (data.pirinfo !== null)
            //         initCalcFromRateTable(JSON.parse(data.pirinfo), Number(pdirate.maximum));
            // } else {
            //     const diinfoCard = document.getElementById('diinfoCard');
            //     diinfoCard.style.display = "none";
            //     if (data.pirinfo !== null)
            //         initCalcFromRateTable(JSON.parse(data.pirinfo), 0);
            // }
        } catch (e) {
            console.error(e.message);
            return null;
        }
    });


    /* (옵션) 탭은 데모용 상태토글 */
    document.querySelectorAll('.tab').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        });
    });

    // 기준일자(오늘) 표시
    const now = new Date();
    const y = now.getFullYear(), m = String(now.getMonth() + 1).padStart(2, '0'),
        d = String(now.getDate()).padStart(2, '0');
    const ref = `${y}-${m}-${d}`;
    const refEl = document.getElementById('rateRefDate');
    if (refEl) refEl.textContent = ref;

    // 탭-패널 매핑
    const tabBtns = document.querySelectorAll('.tabs .tab');
    const panels = {
        guide: document.getElementById('panel-guide'),
        rate: document.getElementById('panel-rate'),
        terms: document.getElementById('panel-terms'),
    };

    // 탭 전환
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            // 탭 active/aria
            tabBtns.forEach(b => {
                b.classList.remove('active');
                b.setAttribute('aria-selected', 'false');
            });
            btn.classList.add('active');
            btn.setAttribute('aria-selected', 'true');

            // 패널 전환
            const key = btn.dataset.tab;           // guide | rate | terms
            Object.values(panels).forEach(p => p.classList.remove('active'));
            panels[key].classList.add('active');

            // 스크롤 보정(선택): 탭 전환 시 본문 상단으로
            // panels[key].scrollIntoView({block:'start', behavior:'smooth'});
        });
    });

    /* 상품 데이터 삽입 */
    async function fetchProduct() {
        try {
            const pid = document.getElementById('script')?.dataset.pid;
            if (!pid) throw new Error('pid 없음');
            const response = await fetch(`/BNK/product/details/${pid}`, {method: "GET"});
            // console.log(response);
            if (!response.ok) throw new Error('상품 정보를 가져오는 도중 문제 발생');
            const productInfo = await response.json();
            console.log(productInfo);
            return productInfo;
        } catch (e) {
            console.error(e);
        }
    }

    function renderProduct(productInfo) {
        const title = document.getElementsByClassName('h-title')[0];
        // const subtitle = document.getElementsByClassName('subtitle')[0];
        const pbirate = document.getElementById('baseRate');
        const prprbank = document.getElementById('prprbank');
        // const phirate = document.getElementById('maxRate');
        const pcprd = document.getElementById('contractPeriod');
        const calcRate = document.getElementById('rateBig');
        // const pjnfee = document.getElementById('joinFee');
        // const prmthd = document.querySelector('div[aria-label="가입방법"]');
        // const prmthdValues = (productInfo.prmthd ?? '').split(',')
        //     .map(s => s.trim()).filter(Boolean);
        const calcPeriod = document.getElementById('period');

        const pnameValue = productInfo.pname
        title.innerText = pnameValue;
        prprbank.innerText = pnameValue.substring(0, pnameValue.indexOf(" "));
        pbirate.innerText = productInfo.pbirate.toFixed(2) + '%';
        // phirate.innerText = productInfo.phirate.toFixed(2) + '%';
        const periodValue = productInfo.prmthd;
        pcprd.innerText = periodValue;
        calcPeriod.innerText = periodValue;
        calcPeriod.dataset.months = String(periodValue.substring(0,periodValue.indexOf("년")) * 12);
        // pjnfee.innerText = productInfo.pjnfee;
        calcRate.innerText = productInfo.pbirate.toFixed(2) + '%';
        calcRate.dataset.rate = productInfo.pbirate;

        // if (prmthdValues.length) {
        //     prmthd.style.display = "flex";
        //     for (const prmthdValue of prmthdValues) {
        //         const pill = `<span class="pill">${prmthdValue}</span>`
        //         prmthd.insertAdjacentHTML("beforeend", pill);
        //     }
        // } else {
        //     prmthd.style.display = "none";
        // }
    }

    // 약관 데이터 (원하면 URL을 실제 파일로 교체)
    // const TERMS = [
    //     { title: '예금거래기본약관', link: '#' },
    //     { title: '적립식예금약관', link: '#' },
    //     { title: '주택청약종합저축 특약', link: '#' },
    //     { title: '주택청약종합저축 상품설명서', link: '#' },
    // ];

    function renderTerms(terms) {

        const div = document.querySelector('#panel-terms .card .inner');
        if (!div) return;
        div.innerHTML = `<div>
                            <iframe src="${terms}" style="width: 100%;height:70vh;border:none;" title="약관 페이지">
                            </iframe>
                         </div>`;

        // 클릭/엔터 시 열기
        // ul.querySelectorAll('.doc-item').forEach(li => {
        //     const open = () => {
        //         const href = li.dataset.link;
        //         if (href && href !== '#') window.open(href, '_blank');
        //         // 데모일 땐 알림만
        //         else alert(li.querySelector('.title').textContent + ' 문서를 연결해주세요.');
        //     };
        //     li.addEventListener('click', open);
        //     li.addEventListener('keydown', e => {
        //         if (e.key === 'Enter') open();
        //     });
        // });
    }

    // 초기 렌더 한 번 실행
    // renderTerms();

    const DUMMY_PINFO = [
        {
            "title": "우대이율",
            "children": [
                {
                    "content": "개인형 우대이율 (최대 0.40%p)",
                    "type": "list",
                    "children": [
                        {
                            "content": "저탄소 실천 적금 보유 우대이율 : 0.10%p",
                            "type": "list",
                            "children": [
                                {
                                    "content": "이 예금의 해지 시 저탄소 실천 적금 보유하고있는 경우 적용",
                                    "type": "list"
                                },
                                {
                                    "content": "만기일 당일 해지분은 우대이율 적용",
                                    "type": "list"
                                }
                            ]
                        },
                        {
                            "content": "비대면 채널 가입 또는 종이통장 미발행 우대이율 : 0.10%p",
                            "type": "list",
                            "children": [
                                {
                                    "content": "비대면 채널을 통해 이 예금을 가입하거나 만기일까지 종이통장을 미발행하는 경우 적용",
                                    "type": "list"
                                },
                                {
                                    "content": "단, 종이통장 미발행 우대이율은 개인 및 개인사업자만 적용가능(법인 불가)",
                                    "type": "list"
                                }
                            ]
                        },
                        {
                            "content": "대중교통 이용실적 우대이율 : 0.10%p",
                            "type": "list",
                            "children": [
                                {
                                    "content": [
                                        {
                                            "content": "부산은행 신용(체크)카드 후불교통 이용 실적 발생 월이 가입기간의 2/3개월 이상 존재하는 경우 적용",
                                            "type": "span"
                                        },
                                        {
                                            "content": "(단, 페이형식 결제(삼성페이, 페이코 등) 및 후불 하이패스 이용실적은 제외)",
                                            "color": "red",
                                            "type": "span"
                                        },
                                        {
                                            "content": "※ 대중교통의 범위 : 지하철, 시내버스, 시외버스, 공항버스",
                                            "type": "span"
                                        }
                                    ],
                                    "type": "list"
                                },
                                {
                                    "content": "만기일 전일까지 매월 말일 기준 실적 보유",
                                    "type": "list"
                                }
                            ]
                        },
                        {
                            "content": "탄소포인트제 참여 우대이율 : 0.10%p",
                            "type": "list",
                            "children": [
                                {
                                    "content": "정부(https://cpoint.or.kr)에서 시행하는 '탄소포인트제'에 참여하고 만기일 전일까지 '탄소포인트제 가입 확인서'를 은행에 제시하는 경우 적용(영업점 창구를 통한 대면 제시 또는 모바일뱅킹을 통해 사진 촬영하여 제시)",
                                    "type": "list"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        {
            "title": "예상 수취이자액 안내",
            "children": [
                {
                    "type": "table",
                    "children": [
                        {
                            "type": "tr",
                            "children": [
                                {"content": "가입금액", "type": "th", "colspan": null, "rowspan": null},
                                {"content": "계약기간", "type": "th", "colspan": null, "rowspan": null},
                                {"content": "적용금리", "type": "th", "colspan": null, "rowspan": null},
                                {"content": "총 이자 (세전)", "type": "th", "colspan": null, "rowspan": null}
                            ]
                        },
                        {
                            "type": "tr",
                            "children": [
                                {"content": "10,000,000원", "type": "td", "colspan": null, "rowspan": null},
                                {"content": "12개월", "type": "td", "colspan": null, "rowspan": null},
                                {"content": "연 2.45%", "type": "td", "colspan": null, "rowspan": null},
                                {"content": "245,000원", "type": "td", "colspan": null, "rowspan": null}
                            ]
                        }
                    ]
                },
                {
                    "type": "p",
                    "content": "- 가입액 • 계약기간 • 적용금리 등 계약세부사항에 따라 변동될 수 있음"
                }
            ]
        }
    ]

    function configureHtml(infoJson, html, parentType = null, stage = 0) {
        switch (infoJson.type) {
            case "list":
                if (stage !== 0) html += `<br>`;
                console.log(stage);
                html += `<ul><li>`;
                // console.log('list stage = ' + stage + ' content = ' + infoJson.content
                //     + ' type = ' + infoJson.type + ' children = ' + infoJson.children);
                if (Array.isArray(infoJson.content)) {
                    for (const [i, v] of infoJson.content.entries()) {
                        html = configureHtml(v, html);
                        if (i !== infoJson.content.length - 1) {
                            html += '<br>';
                            console.log('text index = ' + i);
                        }
                    }
                } else {
                    html += `${infoJson.content}`;
                }
                if (infoJson.children !== undefined) {
                    for (const listItem of infoJson.children) {
                        stage += 1;
                        html = configureHtml(listItem, html, infoJson.type, stage);
                        stage -= 1;
                    }
                }
                html += `</li></ul>`;
                break;
            case "span":
                if (infoJson.color != null) {
                    html += `<span style="color: ${infoJson.color}">${infoJson.content}</span>`;
                } else {
                    html += `<span>${infoJson.content}</span>`;
                }
                // console.log('text else : ' + infoJson.content);
                break;
            case "p":
                if (infoJson.color != null) {
                    html += `<p style="color: ${infoJson.color}">${infoJson.content}</p>`;
                } else {
                    html += `<p>${infoJson.content}</p>`;
                }
                break;
            case "table":
                html += '<table>';
                for (const tr of infoJson.children) {
                    html += '<tr style="text-align: center;">';
                    for (const td of tr.children) {
                        switch (td.type) {
                            case "th":
                                html += `<th ${td.colspan ? 'colspan="' + td.colspan + '" ' : ''}`
                                    + `${td.rowspan ? 'rowspan="' + td.rowspan + '"' : ''}>`
                                    + `${td.content}</th>`;
                                break;
                            case "td":
                                html += `<td ${td.colspan ? 'colspan="' + td.colspan + '"' : ''}`
                                    + `${td.rowspan ? 'rowspan="' + td.rowspan + '"' : ''}>`
                                    + `${td.content}</td>`;
                                break;
                        }
                    }
                    html += `</tr>`;
                    // console.log(html);
                }
                html += `</table>`;
        }
        return html;
    }

    function renderInfo(pinfo) {
        const prodInfo = document.getElementById('prodInfo');
        let productInfo = null;
        try {
            productInfo = JSON.parse(pinfo);
        } catch (e) {
            console.error('JSON 파싱 실패');
        }
        let htmls = "";
        for (const element of productInfo) {
            htmls += `<div class="feature-list">`;
            htmls += `<div class="feature-title"><h4>${element.title}</h4></div>`;
            if (Array.isArray(element.children)) {
                for (const child of element.children) {
                    htmls = configureHtml(child, htmls);
                    // console.log(htmls);
                    // console.log(child);
                }
            } else {
                configureHtml(element, htmls);
            }
            htmls += `</div>`;

        }
        prodInfo.innerHTML = htmls;
        // console.log(htmls);
    }

    // renderInfo(JSON.stringify(DUMMY_PINFO));

    const DUMMY_IRINFO = [
        [
            {"content": "만기지급", "colspan": null, "rowspan": 5},
            {"content": "3개월이상 6개월미만", "colspan": null, "rowspan": null},
            {"content": "1.90", "colspan": null, "rowspan": null},
            {"content": "1.91", "colspan": null, "rowspan": null},
            {"content": "", "colspan": null, "rowspan": null}
        ],
        [
            {"content": "6개월이상 12개월미만", "colspan": null, "rowspan": null},
            {"content": "1.95", "colspan": null, "rowspan": null},
            {"content": "1.96", "colspan": null, "rowspan": null},
            {"content": "", "colspan": null, "rowspan": null}
        ],
        [
            {"content": "12개월이상 24개월미만", "colspan": null, "rowspan": null},
            {"content": "2.05", "colspan": null, "rowspan": null},
            {"content": "2.05", "colspan": null, "rowspan": null},
            {"content": "", "colspan": null, "rowspan": null}
        ],
        [
            {"content": "24개월이상 36개월미만", "colspan": null, "rowspan": null},
            {"content": "1.80", "colspan": null, "rowspan": null},
            {"content": "1.78", "colspan": null, "rowspan": null},
            {"content": "", "colspan": null, "rowspan": null}
        ],
        [
            {"content": "36개월", "colspan": null, "rowspan": null},
            {"content": "1.80", "colspan": null, "rowspan": null},
            {"content": "1.77", "colspan": null, "rowspan": null},
            {"content": "", "colspan": null, "rowspan": null}
        ]
    ];

    function renderIRInfo(pirinfo) {
        const div = document.querySelector('#panel-rate .card .inner');
        if (!div) return;
        div.innerHTML = `<div>
                            <iframe src="${pirinfo}" style="width: 100%;height:70vh;border:none;" title="약관 페이지">
                            </iframe>
                         </div>`;
    }

    // renderIRInfo(DUMMY_IRINFO);

    function renderDIInfo(pdirate) {
        const diinfoHeader = document.getElementById('diinfoHeader');
        const prodDiinfo = document.getElementById('prodDiinfo');
        diinfoHeader.innerText = `우대금리(최대 ${pdirate.maximum}%)`;
        prodDiinfo.innerHTML = pdirate.content.map(li => `<li>${li}</li>`).join('');
    }
});