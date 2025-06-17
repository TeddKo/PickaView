//
//  ChartView.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/14/25.
//

import Foundation
import UIKit
import DGCharts

final class ChartView: BarChartView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    private func commitInit() {
        self.noDataText = "Empty Data"
        self.chartDescription.enabled = false
        self.legend.enabled = false
        
        self.xAxis.labelPosition = .bottom
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.granularity = 1
        
        self.rightAxis.enabled = false
        self.doubleTapToZoomEnabled = false
        self.pinchZoomEnabled = false
        self.highlightPerTapEnabled = false
        self.dragEnabled = false
        self.leftAxis.axisMinimum = 0
        
        self.legend.enabled = true
    }
    
    public func setData(with histories: [History]) {
        let entries: [BarChartDataEntry] = histories
            .enumerated()
            .map { index, history in
                let watchTimeInMinutes = history.time / 60
                return BarChartDataEntry(x: Double(index), y: watchTimeInMinutes)
            }
        
        let dataSet = BarChartDataSet(entries: entries, label: "Watch Time (min)")
        dataSet.colors = [.main]
        dataSet.valueFont = .preferredFont(forTextStyle: .caption1)
        dataSet.valueTextColor = .label
        
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.5
        self.data = chartData
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let dateLabels = histories.map { history -> String in
            guard let date = history.date else { return "" }
            return dateFormatter.string(from: date)
        }
        
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
        
        self.notifyDataSetChanged()
    }
}
