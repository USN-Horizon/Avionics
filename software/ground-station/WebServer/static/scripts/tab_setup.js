export function SetupTabs() {
    const tabs = document.querySelectorAll(".tab");
    const contents = document.querySelectorAll(".tab-content");

    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            // Remove active from all tabs and content tabs
            tabs.forEach(t => t.classList.remove("active"));
            contents.forEach(c => c.classList.remove("active"));

            // Activate this tab
            tab.classList.add("active");

            const target = document.getElementById(tab.dataset.tab);

            // Activate this content tab
            target.classList.add("active");
        });
    });
}