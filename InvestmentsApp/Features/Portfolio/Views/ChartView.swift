//
//  ChartView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 20.06.2022.
//

import SwiftUI

struct ChartView: View {
    var chartData: [PortfolioViewModel.ChartData] = []
    
    private var maxY: Double = 0
    private var minY: Double = 0
    private var lineColor: Color = .primary
    
    @State private var animationDone = false
    @State private var percentage: CGFloat = 0
    
    init(chartData: [PortfolioViewModel.ChartData]) {
        self.chartData = chartData
        print("chartview init \(chartData.count)")
        maxY = chartData.map({ $0.value }).max() ?? 0
        minY = chartData.map({ $0.value }).min() ?? 0
        lineColor = (chartData.last?.value ?? 0 >= chartData.first?.value ?? 0) ? .green : .red
    }
    
    var body: some View {
        VStack {
            chartView
                .frame(height: 200)
                .background(chartBackground)
                .overlay(chartYAxis.padding(.horizontal, 4), alignment: .leading)
            
            chartDateLabels
                .padding(.horizontal, 4)
        }
        .font(.caption)
        .foregroundColor(Color.themeSecondaryText)
        .onAppear {
            if !animationDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.linear(duration: 2.0)) {
                        percentage = 1.0
                    }
                    animationDone = true
                }
            }
        }
    }
    
    private var chartView: some View {
        GeometryReader { gr in
            Path { path in
                for index in chartData.indices {
                    let x = CGFloat(index + 1) / CGFloat(chartData.count) * gr.size.width
                    let y = (1 - CGFloat((chartData[index].value - minY) / (maxY - minY))) * gr.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 10, x: 0.0, y: 10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0.0, y: 20)
            .shadow(color: lineColor.opacity(0.2), radius: 10, x: 0.0, y: 30)
            .shadow(color: lineColor.opacity(0.1), radius: 10, x: 0.0, y: 40)
        }
    }
    
    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var chartYAxis: some View {
        VStack {
            Text(maxY.toCurrencyString())
            Spacer()
            Text(((maxY + minY) / 2).toCurrencyString())
            Spacer()
            Text(minY.toCurrencyString())
        }
    }
    
    private var chartDateLabels: some View {
        HStack {
            Text(chartData.first?.date.toString() ?? "")
            Spacer()
            Text(chartData.last?.date.toString() ?? "")
        }
    }
}

