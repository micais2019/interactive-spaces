window.chartColors = {
  gold: '#ffda5a',
  blue: '#325597',
  pink: '#C2498A',
  white: '#fff',
}

function buildTable(node, data) {
  data.forEach(d => {
    var row = document.createElement('tr')
    row.innerHTML = `<td class="time">${d.created_at}</td><td class="value">${d.value}</td>`
    node.appendChild(row)
  })
}

window.onload = function () {
  // 1. Request charting data from Adafruit IO
  fetch("https://io.adafruit.com/api/v2/mica_ia/feeds/motion/data/chart?hours=720").then(function (response) {
    return response.json()
  }).then(function (response) {

    // 2. Parse the data from Adafruit IO to put it in a format Chart.js is okay with.
    var labels = response.data.map(function (point) {
      return point[0]
    })
    var data = response.data.map(function (point) {
      return parseFloat(point[1])
    })
    // console.log("loaded", data, labels)

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

  fetch("https://io.adafruit.com/api/v2/mica_ia/feeds/motion/data?limit=10").then(function (response) {
    return response.json()
  }).then(data => {
    console.log("GOT", data)
    var tbl = document.querySelector("#motion-1-data")
    buildTable(tbl, data)
  })

  fetch("https://io.adafruit.com/api/v2/mica_ia/feeds/motion-2/data?limit=10").then(function (response) {
    return response.json()
  }).then(data => {
    console.log("GOT", data)
    var tbl = document.querySelector("#motion-2-data")
    buildTable(tbl, data)
  })

}

