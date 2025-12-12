document.addEventListener('DOMContentLoaded', function() {
    
    // --- Data Store (from SQL Results) ---
    const dashboardData = {
        executive: {
            totalSales2021: 173.3, // Millions
            totalSales2020: 92.7,
            products2021: 334,
            products2020: 245,
            markets: 27,
            growth: 86.9 // %
        },
        salesTrend: {
            labels: ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
            data2021: [9.3, 13.2, 20.5, 12.9, 19.6, 15.1, 12.3, 11.5, 10.8, 11.5, 18.3, 18.4], // Millions
        },
        channelMix: {
            labels: ['Retailer', 'Distributor', 'Direct'],
            data: [73.2, 11.3, 15.5], // %
            colors: ['#0066CC', '#FF9900', '#00CC66']
        },
        productGrowth: {
            segments: ['Notebook', 'Accessories', 'Peripherals', 'Desktop', 'Storage', 'Networking'],
            count2020: [92, 69, 59, 7, 12, 6],
            count2021: [108, 103, 75, 22, 17, 9]
        },
        topProducts: { // Top 5 by Revenue (Simulated based on top sellers)
            labels: ['AQ HOME Allin1', 'AQ Pen Drive 2in1', 'AQ Gamers Ms', 'AQ Digit', 'AQ Master Wired'],
            data: [215, 180, 156, 134, 128] // Millions (Est)
        },
        quarterlyVolume: {
            quarters: ['Q1 (Sep-Nov)', 'Q2 (Dec-Feb)', 'Q3 (Mar-May)', 'Q4 (Jun-Aug)'],
            fy2020: [7.0, 6.6, 2.0, 4.0], // Millions
            fy2021: [8.5, 9.2, 7.9, 8.2] 
        },
        markets: [
            { name: 'India', value: '$161M', grow: true },
            { name: 'Indonesia', value: '$43M', grow: true },
            { name: 'S.Korea', value: '$37M', grow: true },
            { name: 'Japan', value: '$22M', grow: true },
            { name: 'Philippines', value: '$18M', grow: true },
            { name: 'Australia', value: '$15M', grow: true },
            { name: 'New Zealand', value: '$9M', grow: true },
            { name: 'Bangladesh', value: '$6M', grow: false }
        ],
        segmentDist: {
            labels: ['Notebook', 'Accessories', 'Peripherals', 'Desktop', 'Storage', 'Networking'],
            data: [32.4, 29.1, 21.1, 8.0, 6.8, 2.3]
        },
        topDiscounts: {
            labels: ['Flipkart', 'Viveks', 'Ezone', 'Croma', 'Amazon'],
            data: [30.83, 30.38, 30.28, 30.25, 29.33]
        },
        discountHist: {
            labels: ['0-5%', '5-10%', '10-15%', '15-20%', '20-25%', '25-30%+', ],
            data: [5, 45, 60, 20, 10, 5] // simulated distribution
        }
    };

    // --- Navigation Logic ---
    const navButtons = document.querySelectorAll('.nav-btn');
    const pages = document.querySelectorAll('.dashboard-page');

    navButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            // Remove active class from all
            navButtons.forEach(b => b.classList.remove('active'));
            pages.forEach(p => p.classList.remove('active'));

            // Add active to current
            btn.classList.add('active');
            const tabId = btn.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // --- Chart Rendering Functions ---
    const ctxTrend = document.getElementById('salesTrendChart').getContext('2d');
    new Chart(ctxTrend, {
        type: 'line',
        data: {
            labels: dashboardData.salesTrend.labels,
            datasets: [{
                label: 'Gross Sales (Millions)',
                data: dashboardData.salesTrend.data2021,
                borderColor: '#003366',
                backgroundColor: 'rgba(0, 51, 102, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    const ctxChannel = document.getElementById('channelDonutChart').getContext('2d');
    new Chart(ctxChannel, {
        type: 'doughnut',
        data: {
            labels: dashboardData.channelMix.labels,
            datasets: [{
                data: dashboardData.channelMix.data,
                backgroundColor: dashboardData.channelMix.colors,
                hoverOffset: 4
            }]
        },
        options: { cutout: '60%', responsive: true, maintainAspectRatio: false }
    });

    const ctxGrowth = document.getElementById('productGrowthChart').getContext('2d');
    new Chart(ctxGrowth, {
        type: 'bar',
        data: {
            labels: dashboardData.productGrowth.segments,
            datasets: [
                {
                    label: '2020',
                    data: dashboardData.productGrowth.count2020,
                    backgroundColor: '#999999'
                },
                {
                    label: '2021',
                    data: dashboardData.productGrowth.count2021,
                    backgroundColor: '#0066CC'
                }
            ]
        },
        options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false }
    });

    // Top Products Horizontal Bar
    const ctxTopProd = document.getElementById('topProductsChart').getContext('2d');
    new Chart(ctxTopProd, {
        type: 'bar',
        data: {
            labels: dashboardData.topProducts.labels,
            datasets: [{
                label: 'Revenue ($M)',
                data: dashboardData.topProducts.data,
                backgroundColor: ['#003366', '#004C99', '#0066CC', '#3399FF', '#66B2FF']
            }]
        },
        options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false }
    });

    // Quarterly Sales Stacked Bar
    const ctxQuarter = document.getElementById('quarterlySalesChart').getContext('2d');
    new Chart(ctxQuarter, {
        type: 'bar',
        data: {
            labels: dashboardData.quarterlyVolume.quarters,
            datasets: [
                 {
                    label: '2020 Volume',
                    data: dashboardData.quarterlyVolume.fy2020,
                    backgroundColor: '#999999'
                },
                {
                    label: '2021 Volume',
                    data: dashboardData.quarterlyVolume.fy2021,
                    backgroundColor: '#0066CC'
                }
            ]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    // Top Discount Customers
    const ctxDisc = document.getElementById('topDiscountCustomersChart').getContext('2d');
    new Chart(ctxDisc, {
        type: 'bar',
        data: {
            labels: dashboardData.topDiscounts.labels,
            datasets: [{
                label: 'Avg Discount %',
                data: dashboardData.topDiscounts.data,
                backgroundColor: '#CC3333'
            }]
        },
        options: { 
            indexAxis: 'y', 
            responsive: true, 
            maintainAspectRatio: false,
            scales: { x: { beginAtZero: true, suggestedMax: 35 } } 
        }
    });

    // Discount Histogram
    const ctxHist = document.getElementById('discountHistogramChart').getContext('2d');
    new Chart(ctxHist, {
        type: 'bar',
        data: {
            labels: dashboardData.discountHist.labels,
            datasets: [{
                label: 'Customer Count',
                data: dashboardData.discountHist.data,
                backgroundColor: '#00CC66'
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

     // Segment Treemap (simulated as Pie for simplicity in Chart.js basic)
     const ctxTree = document.getElementById('segmentTreemapChart').getContext('2d');
     new Chart(ctxTree, {
         type: 'pie', // Fallback for standard Chart.js
         data: {
             labels: dashboardData.segmentDist.labels,
             datasets: [{
                 data: dashboardData.segmentDist.data,
                 backgroundColor: ['#003366', '#0066CC', '#00CC66', '#FF9900', '#CC3333', '#666666']
             }]
         },
         options: { responsive: true, maintainAspectRatio: false }
     });

    // --- Render Top Products Matrix (HTML) ---
    const matrixContainer = document.getElementById('topProductsMatrix');
    const matrixHTML = `
        <table class="matrix-table">
            <thead>
                <tr>
                    <th>Division</th>
                    <th>Rank 1 (Gold)</th>
                    <th>Rank 2 (Silver)</th>
                    <th>Rank 3 (Bronze)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>P & A</strong></td>
                    <td class="rank-1">AQ Gamers Ms (4.3M)</td>
                    <td class="rank-2">AQ Master wireless (4.1M)</td>
                    <td class="rank-3">AQ Master wired (3.9M)</td>
                </tr>
                 <tr>
                    <td><strong>N & S</strong></td>
                    <td class="rank-1">AQ Pen Drive 2in1 (3.9M)</td>
                    <td class="rank-2">AQ Pen Drive DRC (3.7M)</td>
                    <td class="rank-3">AQ Clx1 (3.5M)</td>
                </tr>
                <tr>
                    <td><strong>PC</strong></td>
                    <td class="rank-1">AQ Digit (17k)</td>
                    <td class="rank-2">AQ Velocity (17k)</td>
                    <td class="rank-3">AQ Digit Blue (17k)</td>
                </tr>
            </tbody>
        </table>
    `;
    matrixContainer.innerHTML = matrixHTML;

    // --- Render Market Grid (HTML) ---
    const marketContainer = document.getElementById('marketGrid');
    dashboardData.markets.forEach(m => {
        const div = document.createElement('div');
        div.className = `market-bubble ${m.grow ? 'highlight' : ''}`;
        div.innerHTML = `<div class="market-name">${m.name}</div><div class="market-val">${m.value}</div>`;
        marketContainer.appendChild(div);
    });

    // --- Fiscal Year Toggle (Simulated) ---
    const buttons = document.querySelectorAll('#fy-filter button');
    buttons.forEach(btn => {
        btn.addEventListener('click', () => {
             buttons.forEach(b => b.classList.remove('active'));
             btn.classList.add('active');
             // In a real app, this would re-render charts.
             // Here we just indicate functionality.
             alert(`Fiscal Year set to ${btn.getAttribute('data-value')}. Data refreshed (Simulation).`);
        });
    });
});
