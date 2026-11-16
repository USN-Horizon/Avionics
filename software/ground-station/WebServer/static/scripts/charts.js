const chart_data_points = 30;

var charts_map = new Map();

export function UpdateGraph(label, value, graph_name) {
    const charts = charts_map.get(graph_name);

    if (!charts) return;

    if (value == null || value == "N/A") {
        value = 0;
    }

    charts.forEach((chart) => {
        chart.data.labels = chart.data.labels.splice(1 - chart_data_points);
        chart.data.labels.push(label);
        chart.data.datasets[0].data = chart.data.datasets[0].data.splice(1 - chart_data_points);
        chart.data.datasets[0].data.push(value);
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
                    x: {
                        ticks: {
                            font: {
                                size: 10
                            }
                        }
                    },
                    y : {
                        beginAtZero: true,
                        grid: {
                            color: (context) =>
                            context.tick.value === 0 ? '#000' : '#ddd',
                            lineWidth: (context) =>
                            context.tick.value === 0 ? 2 : 1
                        }
                    }
                },
                elements: {
                    point: {
                        radius: 2,
                        hoverRadius: 5
                    }
                }
            }
        });

        charts_map.getOrInsert(canvas.dataset.data_name, []).push(chart);
    });
}