//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Robert Bernardini on 6/02/22.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    struct StockData {
        let oneHour: [StockEntry]
        let oneDay: [StockEntry]
        let oneWeek: [StockEntry]
        let oneMonth: [StockEntry]
        let oneYear: [StockEntry]
    }
    
    enum TimePeriod {
        case oneHour
        case oneDay
        case oneWeek
        case oneMonth
        
        case oneYear
        
        func stockEntries(from stockData: StockData) -> [StockEntry] {
            switch self {
            case .oneHour: return stockData.oneHour
            case .oneDay: return stockData.oneDay
            case .oneWeek: return stockData.oneWeek
            case .oneMonth: return stockData.oneMonth
            case .oneYear: return stockData.oneYear
            }
        }
    }
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.accessibilityTraits = .updatesFrequently
        label.accessibilityLabel = "Stock price"
        return label
    }()

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.delegate = self
        
        chartView.isAccessibilityElement = true
        chartView.rightAxis.enabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .preferredFont(forTextStyle: .body)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.labelPosition = .outsideChart
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .preferredFont(forTextStyle: .body)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .black
        xAxis.axisLineColor = .black
        xAxis.labelPosition = .bottom
        xAxis.labelRotationAngle = 45
        xAxis.valueFormatter = axisFormatDelegate
        
        chartView.animate(xAxisDuration: 1)
        
        chartView.accessibilityTraits = .updatesFrequently
        
        return chartView
    }()
    
    var stockData: StockData?
    var currentStockEntries: [StockEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        axisFormatDelegate = self
        view.addSubview(priceLabel)
        view.addSubview(lineChartView)
        setConstraints()
        fetchStockData()
        setChartData(for: .oneYear)
    }
}

private extension ViewController {
    
    func setConstraints() {
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            lineChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineChartView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lineChartView.widthAnchor.constraint(equalTo: view.widthAnchor),
            lineChartView.heightAnchor.constraint(equalTo: view.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setChartData(for timePeriod: TimePeriod) {
        guard let stockData = stockData else { return }
        currentStockEntries = timePeriod.stockEntries(from: stockData)
        let set = LineChartDataSet(entries: currentStockEntries.map({ ChartDataEntry(x: $0.x, y: $0.y, data: $0) }))
        set.mode = .cubicBezier
        set.drawCirclesEnabled = true
        set.circleColors = [.clear]
        set.drawCircleHoleEnabled = false
        set.lineWidth = 2
        set.setColor(.green)
        set.fill = Fill(color: .green)
        set.fillAlpha = 0.3
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        lineChartView.data = data
        
        updatePriceLabel(with: currentStockEntries.last?.price ?? "Error")
    }
    
    func updateAccessibilityFrames() {
        if let elements = lineChartView.accessibilityChildren() as? [NSUIAccessibilityElement] {
            let chartContentRect = lineChartView.contentRect
            elements.forEach({
                let oldFrame = $0.accessibilityFrame
                $0.accessibilityFrame = CGRect(
                    x: oldFrame.origin.x,
                    y: chartContentRect.origin.y,
                    width: oldFrame.width,
                    height: chartContentRect.height
                )
            })
        }
    }
    
    func updatePriceLabel(with price: String) {
        priceLabel.text = price
        priceLabel.accessibilityValue = price
    }
}

private extension ViewController {
    
    func fetchStockData() {
        guard let url = Bundle.main.url(forResource: "AppleSharesOneYear", withExtension: "json"),
              let jsonData = try? String(contentsOf: url).data(using: .utf8),
              let stockEntriesOneYear = try? JSONDecoder().decode([StockEntry].self, from: jsonData) else { return }
        
        guard let url = Bundle.main.url(forResource: "AppleSharesOneMonth", withExtension: "json"),
              let jsonData = try? String(contentsOf: url).data(using: .utf8),
              let stockEntriesOneMonth = try? JSONDecoder().decode([StockEntry].self, from: jsonData) else { return }
        
        guard let url = Bundle.main.url(forResource: "AppleSharesOneWeek", withExtension: "json"),
              let jsonData = try? String(contentsOf: url).data(using: .utf8),
              let stockEntriesOneWeek = try? JSONDecoder().decode([StockEntry].self, from: jsonData) else { return }
        
        guard let url = Bundle.main.url(forResource: "AppleSharesOneDay", withExtension: "json"),
              let jsonData = try? String(contentsOf: url).data(using: .utf8),
              let stockEntriesOneDay = try? JSONDecoder().decode([StockEntry].self, from: jsonData) else { return }
        
        guard let url = Bundle.main.url(forResource: "AppleSharesOneHour", withExtension: "json"),
              let jsonData = try? String(contentsOf: url).data(using: .utf8),
              let stockEntriesOneHour = try? JSONDecoder().decode([StockEntry].self, from: jsonData) else { return }
        
        stockData = StockData(
            oneHour: stockEntriesOneHour.reversed(),
            oneDay: stockEntriesOneDay.reversed(),
            oneWeek: stockEntriesOneWeek.reversed(),
            oneMonth: stockEntriesOneMonth.reversed(),
            oneYear: stockEntriesOneYear.reversed()
        )
    }
}

extension ViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let stockEntryData = entry.data as? StockEntryData else { return }
        updatePriceLabel(with: stockEntryData.price)
    }
}

extension ViewController: IAxisValueFormatter {
    // Delegate function to set date labels on x-axis.
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

//@available(iOS 15, *)
//extension LineChartView: AXChart {
//    
//    public var accessibilityChartDescriptor: AXChartDescriptor? {
//        get {
//            guard let set = data?.dataSets.first else { return nil }
//            return makeAccessibilityChartDescriptor(for: set)
//        }
//        set {}
//    }
//    
//    
//    private func makeAccessibilityChartDescriptor(for dataSet: IChartDataSet) -> AXChartDescriptor? {
//        let audioDataPoints = dataSet.map({ AXDataPoint(x: $0., y: $0.y) })
//        let series = AXDataSeriesDescriptor(
//            name: "Apple share price",
//            isContinuous: false,
//            dataPoints: audioDataPoints
//        )
//
//        guard let firstX = stockEntries.first?.x, let lastX = stockEntries.last?.x else { return nil }
//        let dateAxisDescriptor = AXNumericDataAxisDescriptor(
//            title: "Date",
//            range: firstX...lastX,
//            gridlinePositions: []) { xValue in
//                let date = Date(timeIntervalSince1970: xValue)
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd MMMM yyyy"
//                return dateFormatter.string(from: date)
//            }
//        
//        let priceSortedList = stockEntries.sorted(by: { ($0.price < $1.price) })
//        guard let firstY = priceSortedList.first?.y, let lastY = priceSortedList.last?.y else { return nil }
//        let priceAxisDescriptor = AXNumericDataAxisDescriptor(
//            title: "Share price",
//            range: firstY...lastY,
//            gridlinePositions: []) { yValue in
//                let formatter = NumberFormatter()
//                formatter.locale = Locale.current
//                formatter.numberStyle = .currency
//                return formatter.string(from: yValue as NSNumber) ?? ""
//            }
//        
//        let title = "Apple share price"
//        let summary = "The chart shows the apple share price at each date"
//        
//        return AXChartDescriptor(
//            title: title,
//            summary: summary,
//            xAxis: dateAxisDescriptor,
//            yAxis: priceAxisDescriptor,
//            additionalAxes: [],
//            series: [series]
//        )
//    }
//}
//
//extension LineChartView {
//    open override var accessibilityContainerType: UIAccessibilityContainerType {
//        get {
//            return .semanticGroup
//        }
//        set {}
//    }
//}
