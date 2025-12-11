document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".rp-tab-menu li a");
    const contents = document.querySelectorAll(".rp-tab-content");

    tabs.forEach(tab => {
        tab.addEventListener("click", function (e) {
            e.preventDefault();
            const target = this.getAttribute("href");

            // 탭 active 변경
            document.querySelectorAll(".rp-tab-menu li")
                .forEach(li => li.classList.remove("active"));
            this.parentElement.classList.add("active");

            // 콘텐츠 표시 변경
            contents.forEach(c => c.style.display = "none");
            document.querySelector(target).style.display = "block";
        });
    });
});
