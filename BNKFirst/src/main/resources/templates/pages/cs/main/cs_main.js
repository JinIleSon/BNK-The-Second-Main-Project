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

///////////////////////
//  카테고리 영역
///////////////////////
const categoryList = document.querySelector('.category-list');

  const categories = [
    { icon: 'icon_inquiry.svg', title: '고객의견 보내기', desc: '문의, 칭찬, 불만 의견을 남겨주세요.', link: '#' },
    { icon: 'icon_lost.svg', title: '분실/도난 신고하기', desc: '카드나 통장을 빠르게 정지시킬 수 있습니다.', link: '#' },
    { icon: 'icon_reserve.svg', title: '예약상담 신청하기', desc: '전문 상담사와 맞춤 상담을 예약하세요.', link: '#' },
    { icon: 'icon_doc.svg', title: '증명서 발급신청', desc: '각종 증명서와 확인서를 신청할 수 있습니다.', link: '#' },
    { icon: 'icon_fee.svg', title: '수수료 안내', desc: '서비스별 수수료 정보를 확인하세요.', link: '#' },
    { icon: 'icon_branch.svg', title: '지점 안내', desc: '가까운 지점과 영업시간을 안내해드립니다.', link: '#' }
  ];

  categoryList.innerHTML = categories.map(cat => `
    <div class="category-item">
      <img src="${cat.icon}" alt="">
      <h4>${cat.title}</h4>
      <p>${cat.desc}</p>
      <a href="${cat.link}">바로가기 ></a>
    </div>
  `).join('');