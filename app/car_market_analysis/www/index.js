console.log("index.js loaded")
var i ;
// Getting info from server
Shiny.addCustomMessageHandler("dataChartJS_scatter", function(data) {
//  dailyChart(data);
i = data
chartGenOrig(data)
}) 


function chartGenOrig(data) {
    $(".countries-stats").empty();
    $(".countries-stats").append(
    '<canvas id="countries-stats"></canvas>'
    );
  // get canvas 
var canvas = document.getElementById("countries-stats");

var dataChart = [];
for (var i = 0; i < Object.keys(data).length; i++){
    dataChart[i] = {
        x: data[i].year,
        y: data[i].price,
        odo: data[i].odo
    }
}
console.log(dataChart)

new Chart(canvas, {
    type:'scatter',
    data: {
        datasets: [
            {
                label: 'It will be name like Select Brand later',
                data: dataChart,
                backgroundColor: data.map(x=>x.color)
            }
        ],
    }
    
})

}

