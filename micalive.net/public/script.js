window.chartColors = {
  gold: '#ffda5a',
  blue: '#325597',
  pink: '#C2498A',
  white: '#fff',
}

window.onload = function () {

  // 1. Request charting data from Adafruit IO
  fetch("https://io.adafruit.com/api/v2/ab_home/feeds/motion/data/chart?hours=720").then(function (response) {
    return response.json()
  }).then(function (response) {

    // 2. Parse the data from Adafruit IO to put it in a format Chart.js is okay with.
    var labels = response.data.map(function (point) {
      return point[0]
    })
    var data = response.data.map(function (point) {
      return parseFloat(point[1])
    })
    console.log("loaded", data, labels)

    // 3. Generate the chart
    var ctx = document.getElementById("data-chart");
    var myChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          data: data,
          backgroundColor: window.chartColors.gold,
          borderColor: window.chartColors.gold,
          pointBackgroundColor: 'transparent', // LINE_COLORS[idx],
          pointBorderColor: 'transparent', // LINE_COLORS[idx],
          pointRadius: 1,
          borderWidth: 2,
          spanGaps: true,

        }]
      },
      options: {
        aspectRatio: 3,
        height: '333px',
        animation: { duration: 0 },
        hover: {
          animationDuration: 0,
          enabled: false,
          display: false,
        },
        responsiveAnimationDuration: 0,
        tooltips: {
          enabled: false
        },
        scales: {
          yAxes: [{
            ticks: {
              fontColor: window.chartColors.white
            },
            gridLines: {
              color: window.chartColors.pink,
            },
          }],
          xAxes: [{
            ticks: {
              fontColor: window.chartColors.white
            },
            gridLines: {
              display: false
            },
          }]
        },
        legend: {
          display: false,
        },
        responsive: true,
        elements: {
          line: {
            tension: 0, // disables bezier curves
          }
        }
      }
    });

  });

}

