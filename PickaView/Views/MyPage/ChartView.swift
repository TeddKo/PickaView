//
//  ChartView.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/14/25.
//

import Foundation
import UIKit
import DGCharts

/// `DGCharts`의 `BarChartView`를 상속받아 커스텀한 차트 뷰.
///
/// 마이페이지에서 시청 시간 통계를 시각적으로 보여주는 역할을 함.
final class ChartView: BarChartView {
    
    /// 코드로 `ChartView`를 초기화함.
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    /// Interface Builder(스토리보드)에서 `ChartView`를 초기화함.
    @MainActor required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    /// 차트의 초기 외형 및 공통 속성을 설정함.
    ///
    /// 설명, 범례, 축, 제스처 등의 기본값을 정의함.
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
    
    /// `History` 데이터 배열을 받아 차트 데이터를 설정하고 UI를 갱신함.
    /// - Parameter histories: 차트에 표시할 `History` 객체 배열.
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
