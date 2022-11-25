console.log("index.js loaded")
var i;
// Getting info from server
Shiny.addCustomMessageHandler("dataChartJS_scatter", function (data) {
    //  dailyChart(data);
    iss = data
    chartGenOrig(data[0], data[1][0], 'Price distribution')
})


function chartGenOrig(dataChartFromShiny, chartType, chartLabel) {
 
    $(".countries-stats").empty();
    $(".countries-stats").append(
        '<canvas id="countries-stats"></canvas>'
    );
    // get canvas 
    var canvas = document.getElementById("countries-stats");
    var randomNum = () => Math.floor(Math.random() * (235 - 52 + 1) + 52);
    var randomRGB = () => `rgb(${randomNum()}, ${randomNum()}, ${randomNum()})`;
    var datasetsChart;
    var  optionsChart;
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
            datasetsChart =
                [{
                    data: dataChartFromShiny.map(x => x.x),
                    fill: true,
                    label: chartLabel,
                }];

    }

    new Chart(canvas, {
        type: chartType == 'bar_stacked'? 'bar': chartType,
        data: {
            labels: [...new Set(dataChartFromShiny.map(x => x.labels))],
            datasets: datasetsChart,
        },
        options: optionsChart


    })

}

