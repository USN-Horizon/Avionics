const tabs = document.querySelectorAll(".tab");
const contents = document.querySelectorAll(".tab-content");

function DeactivateAllTabs() {
     tabs.forEach(tab => {
        // Remove active from all tabs and content tabs
        tabs.forEach(t => t.classList.remove("active"));
        contents.forEach(c => c.classList.remove("active"));
    });
}

function FindFirst(array, predicate) {
  for (var i = 0; i < array.length; i++) {
    if (predicate(array[i])) return array[i];
  }
}

export function SwitchToTabName(tab_name) {
    const tab = FindFirst(tabs, (tab) => { return tab.dataset.tab == tab_name; });
    if (!tab) {
        console.log("Tried switching to tab of name " + tab_name + ", but no tab with that name was found.");
        return;
    }

    DeactivateAllTabs();

    tab.classList.add("active");

    const target = document.getElementById(tab_name);

    // Activate this content tab
    target.classList.add("active");
}

export function SwitchToTabIndex(tab_index) {
    const tab = FindFirst(tabs, (tab) => { return tab.dataset.index == tab_index; });
    if (!tab) {
        console.log("Tried switching to tab of index " + tab_index + ", but no tab with that index was found.");
        return;
    }

    DeactivateAllTabs();

    tab.classList.add("active");

    const target = document.getElementById(tab.dataset.tab);

    // Activate this content tab
    target.classList.add("active");
}

export function SetupTabs() {
    tabs.forEach(tab => {
        tab.addEventListener("click", () => { SwitchToTabName(tab.dataset.tab); });
    });

    document.addEventListener("keyup", (event) => {
        const re = /Digit[1-9]/;

        if (event.code.match(re)) {
            SwitchToTabIndex(event.code.at(event.code.length - 1));
            return;
        }
        else {
            var direction;
            if (event.code == "ArrowLeft") {
                direction = -1;
            }
            else if (event.code == "ArrowRight") {
                direction = 1;
            }
            else {
                return;
            }

            const active_tab = FindFirst(tabs, (tab) => { return tab.classList.contains("active") });
            const next_index = parseInt(active_tab.dataset.index) + direction;
            SwitchToTabIndex(next_index);
        }
    });
}