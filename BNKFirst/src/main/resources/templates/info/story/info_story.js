
// 슬라이더
(()=>{
    const slider=document.getElementById('eventSlider');
    if(!slider)return;
    const slides=slider.querySelector('.slides');
    const dots=[...slider.querySelectorAll('.dot')];
    let i=0;
    function go(n){i=(n+3)%3;slides.style.transform=`translateX(${-100*i}%)`;dots.forEach((d,k)=>d.classList.toggle('active',k===i));}
    slider.querySelector('[data-dir="-1"]').onclick=()=>go(i-1);
    slider.querySelector('[data-dir="1"]').onclick=()=>go(i+1);
    setInterval(()=>go(i+1),4000);
})();