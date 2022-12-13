
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
        drawChart('.chart', data[3], 'bar', 'Price distribution', 0, false, false, 'price', 'Car Brand', 'Quantity on market', true, false);
        drawChart('.chart', data[2], 'bar', 'Price to Odo', 1, false, false, 'price', 'Odometr', 'Price', true, false);
    } else {
        $('.chart').empty();
        drawChart('.chart', data[0], data[1][0], 'Price distribution', 0);
    }

})

// find div clean and draw figure there
function drawChart(divName, dataChartFromShiny, chartType, chartLabel, ids,horizontal, stacked, labels, x_axis_label, y_axis_label, show_grid, show_legend) {
    var canvasId = 'chart-stats-' + ids
    $(divName).eq(ids).empty();
    $(divName).eq(ids).append(
        '<canvas id="' + canvasId + '"></canvas>'
    );
    barChart(canvasId, dataChartFromShiny, chartLabel, horizontal, stacked, labels, x_axis_label,y_axis_label, show_grid, show_legend);

}