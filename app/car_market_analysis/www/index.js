
// Data from side bar 
var filterData;
Shiny.addCustomMessageHandler("filterData", function (data) {
    filterData = data;
})

// data for open tabs 


    Shiny.addCustomMessageHandler("tabModelOpened", function(data){
        tabData = data
    // need to wait a bit untill new tab appears
    setTimeout(() => {
        for (var i = 0; i < Object.keys(tabData).length; i++) {
           var brand = Object.keys(tabData)[i]
            var dataBrand  = data[brand]
            drawChart('.chart-brand', dataBrand, 'bar', brand, i, false, false, 'price', 'Car Brand', 'Count', true, false); 
        }
    },  500);
})

// Getting info from server
Shiny.addCustomMessageHandler("dataChartJS_scatter", function (data) {
    iss = data
        drawChart('.chart', data[3], 'bar', 'Market', 0, false, false, 'price', 'Car Brand', 'Count', true, false);
        drawChart('.chart', data[4], 'bar', 'AVG Price to Year', 1, false, false, 'price', 'Year', 'Price', true, false);
        drawChart('.chart', data[5], 'bar', 'Count to year', 3, false, false, 'price', 'Year', 'Count', true, false);
        drawChart('.chart', data[2], 'bar', 'AVG Price to Odometer', 2, false, false, 'price', 'Odometer', 'Price', true, false);

})

// find div clean and draw figure there
function drawChart(divName, dataChartFromShiny, chartType, chartLabel, ids,horizontal, stacked, labels, x_axis_label, y_axis_label, show_grid, show_legend) {
    var canvasId = divName == ".chart" ? 'chart-stats-' + ids : 'chart-brand-'+ids
    $(divName).eq(ids).empty();
    $(divName).eq(ids).append(
        '<canvas id="' + canvasId + '"></canvas>'
    );
    barChart(canvasId, dataChartFromShiny, chartLabel, horizontal, stacked, labels, x_axis_label,y_axis_label, show_grid, show_legend);

}