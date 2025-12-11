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
