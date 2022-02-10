//
//  Stock.swift
//  ChartsDemo
//
//  Created by Robert Bernardini on 6/02/22.
//

import Foundation

protocol StockEntryData {
    var price: String { get }
    var formattedDate: String { get }
    var accessibilityString: String { get }
}

protocol ChartDataPoint {
    var x: Double { get }
    var y: Double { get }
}

struct StockEntry: Decodable {
    let date: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
}

extension StockEntry: StockEntryData {
    var price: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter.string(from: close as NSNumber) ?? ""
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: date) else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: date) else { return "" }
            dateFormatter.dateFormat = "dd MMMM yyyy"
            return dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    var accessibilityString: String {
        "The price is \(price) at \(formattedDate)"
    }
}

extension StockEntry: ChartDataPoint {
    var x: Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: date) else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: date) else { return 0 }
            return date.timeIntervalSince1970
        }
        return date.timeIntervalSince1970
    }
    
    var y: Double {
        close
    }
}
