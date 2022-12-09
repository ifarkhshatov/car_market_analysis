
// Data from side bar 
var filterData;
Shiny.addCustomMessageHandler("filterData", function (data) {
    filterData = data;
})

// Getting info from server
Shiny.addCustomMessageHandler("dataChartJS_scatter", function (data) {
    //  dailyChart(data);
    iss = data
    if (filterData[1][0] == 'All') {
        drawChart('.chart', data[3], 'bar', 'Price distribution', 0);
        drawChart('.chart', data[2], 'bar', 'Price to Odo', 1);
    } else {
        $('.chart').empty();
        drawChart('.chart', data[0], data[1][0], 'Price distribution', 0);
    }

})


function chartGenOrig(dataChartFromShiny, chartType, chartLabel, canvasId) {
    var randomNum = () => Math.floor(Math.random() * (235 - 52 + 1) + 52);
    var randomRGB = () => `rgb(${randomNum()}, ${randomNum()}, ${randomNum()})`;
    var datasetsChart;
    var optionsChart;
    // preapre data depends on chart type
    switch (chartType) {
        case 'scatter':
            var dataChart = [];
            for (var i = 0; i < Object.keys(dataChartFromShiny).length; i++) {
                dataChart[i] = {
                    x: dataChartFromShiny[i].x,
                    y: dataChartFromShiny[i].y
                }
            }

            datasetsChart = [
                {
                    label: chartLabel,
                    data: dataChart,
                    // backgroundColor: data.map(x=>x.color)
                }
            ];
            break;
        case 'bar_stacked':
            var datasetsChart = [];
            var label = [...new Set(dataChartFromShiny.map(x => x.label))];

            for (var i = 0; i < label.length; i++) {
                datasetsChart[i] = {
                    label: label[i],
                    data: dataChartFromShiny.filter(x => x.label == label[i]).map(x => x.x),
                    fill: true,
                    backgroundColor: randomRGB(),
                }
            }

            optionsChart = {
                scales: {
                    xAxes: [{
                        stacked: true // this should be set to make the bars stacked
                    }],
                    yAxes: [{
                        stacked: true // this also..
                    }]
                },
                plugins: {
                    colorschemes: {
                        scheme: 'brewer.Paired12'
                    }

                },
                responsive: true,
            }
            break;
        //bar or line (not stacked)
        default:
            //default options
            optionsChart = {
                plugins: {
                  // Change options for ALL labels of THIS CHART
                  datalabels: {
                    color: '#36A2EB'
                  }
                },
                responsive: true,
                maintainAspectRatio: false
              }

            //default chart
            datasetsChart =
                [{
                    data: dataChartFromShiny.map(x => x.x),
                    fill: true,
                    label: chartLabel,
                    backgroundColor: '#3c8dbc',
                }];


    }

    // get canvas 
    var canvas = document.getElementById(canvasId);
    new Chart(canvas, {
        type: chartType == 'bar_stacked' ? 'bar' : chartType,
        data: {
            labels: [...new Set(dataChartFromShiny.map(x => x.labels))],
            datasets: datasetsChart,
        },
        options: {
            // responsive:true,
            // maintainAspectRatio: false
        }//optionsChart
    })

}

// find div clean and draw figure there
function drawChart(divName, dataChartFromShiny, chartType, chartLabel, ids) {
    var canvasId = 'chart-stats-' + ids
    $(divName).eq(ids).empty();
    $(divName).eq(ids).append(
        '<canvas id="' + canvasId + '"></canvas>'
    );
    chartGenOrig(dataChartFromShiny, chartType, chartLabel, canvasId);
}