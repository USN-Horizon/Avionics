const chart_data_points = 100;
const chart_update_time_ms = 500;

var charts_map = new Map();

export function UpdateGraph(graph_name, value) {
    const charts = charts_map.get(graph_name);

    if (!charts) return;

    console.log("Updating graph " + graph_name + " = " + value);

    charts.forEach((chart) => {
        chart.data.datasets[0].data[chart_data_points - 1] = value;
        chart.update();
    });
}

export function SetupCharts() {
    if (chart_data_points <= 2) {
        console.log("Amount of datapoints in charts is too low! (" + chart_data_points + ")");
    }

    const chart_canvases = document.querySelectorAll(".data-graph");

    chart_canvases.forEach((canvas) => {
        const chart = new Chart(canvas, {
            type: 'line',
            data: {
                labels: Array(chart_data_points).fill(' '),
                datasets: [{
                    data: Array(chart_data_points).fill(0)
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: {
                    duration: 0, // general animation time
                },
                hover: {
                    animationDuration: 0, // duration of animations when hovering an item
                },
                responsiveAnimationDuration: 0, // animation duration after a resize

                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales : {
                    y : {
                        beginAtZero: true,
                        grid: {
                            color: (context) =>
                            context.tick.value === 0 ? '#000' : '#ddd',
                            lineWidth: (context) =>
                            context.tick.value === 0 ? 2 : 1
                        }
                    }
                }
            }
        });

        charts_map.getOrInsert(canvas.dataset.data_name, []).push(chart);
    })

    var ctr = 0;

    setInterval(() => {
        charts_map.forEach((charts, chart_name, map) => {
            charts.forEach((chart) => {
                chart.data.labels = chart.data.labels.splice(1 - chart_data_points);
                chart.data.labels.push(ctr);
                chart.data.datasets[0].data = chart.data.datasets[0].data.splice(1 - chart_data_points);
                chart.data.datasets[0].data.push(chart.data.datasets[0].data[chart_data_points - 2]);
                chart.update();
            });
        });

        ctr = ctr + 1;
    }, chart_update_time_ms);


    /*
    const canvas = document.getElementById('graph_altitude');

    const chart = new Chart(canvas, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                data: []
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            animation: {
                duration: 0, // general animation time
            },
            hover: {
                animationDuration: 0, // duration of animations when hovering an item
            },
            responsiveAnimationDuration: 0, // animation duration after a resize

            plugins: {
                legend: {
                    display: false
                }
            },
            scales : {
                y : {
                    beginAtZero: true,
                    grid: {
                        color: (context) =>
                        context.tick.value === 0 ? '#000' : '#ddd',
                        lineWidth: (context) =>
                        context.tick.value === 0 ? 2 : 1
                    }
                }
            }
        }
    });
    */

    /*
    const canvas_container = canvas.parentElement;
    const data_segment_container = canvas_container.parentElement;

    function UpdateCanvas() {
        console.log("Resize!");

        canvas.width  = canvas_container.clientWidth;
        canvas.height = canvas_container.clientHeight;
        canvas.style.width = "100%";
        canvas.style.height = "100%";
        chart.update();
    }

    new ResizeObserver(UpdateCanvas).observe(data_segment_container);
    */

    /*
    var ctr = 0;
    var data = []
    var labels = []

    setInterval(() => {
        const text = document.querySelectorAll(".field_altitude")[0];
        
        const value = text.innerHTML;
        if (value == "N/A" || value === undefined) {
            return;
        }

        labels.push(ctr);
        data.push(value);

        chart.data.labels = labels.slice(-20);
        chart.data.datasets[0].data = data.slice(-20);

        chart.update();

        ctr = ctr + 1;
    }, 500);
    */
}