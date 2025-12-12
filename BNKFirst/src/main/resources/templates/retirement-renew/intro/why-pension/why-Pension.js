document.addEventListener("DOMContentLoaded", () => {

    const tabButtons = document.querySelectorAll(".pension-tab button");
    const tabContents = document.querySelectorAll(".tab-content");

    tabButtons.forEach(btn => {
        btn.addEventListener("click", () => {

            tabButtons.forEach(b => b.classList.remove("active"));
            btn.classList.add("active");

            const targetId = btn.dataset.tab;
            tabContents.forEach(c => c.classList.remove("active"));
            document.getElementById(targetId).classList.add("active");
        });
    });

});
