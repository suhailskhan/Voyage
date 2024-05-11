import SwiftUI
import Charts

struct SatelliteAltitudeChart: View {
    @State private var selectedTimeOption: TimeOption = .past24Hours
    @State private var times: [Date] = []
    @State private var xAxisMarks = AxisMarks(values: .stride(by: .hour, count: 4)) { value in
            AxisValueLabel(format: .dateTime.hour())
        }

    var satellite: Satellite

    var body: some View {
        VStack {
            Picker("Select Time Period", selection: $selectedTimeOption) {
                ForEach(TimeOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            
            Chart {
                ForEach(times, id: \.self) { time in
                    LineMark(
                        x: .value("Date", time),
                        y: .value("Altitude", Double(satellite.altitudeAt(time: time)))
                    )
                    .interpolationMethod(.catmullRom) // Smooths the line
                }
            }
            .chartXAxis {
                xAxisMarks
            }
            .chartYAxis {
                AxisMarks()
            }
        }
        .onChange(of: selectedTimeOption, updateTimes)
        .onAppear {
            updateTimes()
        }
    }
    
    func updateTimes() {
        let now = Date()
        switch selectedTimeOption {
        case .past24Hours:
            times = Array(stride(from: now, through: now.addingTimeInterval(-3600 * 23), by: -3600))
            xAxisMarks = AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                AxisValueLabel(format: .dateTime.hour())
            }
        case .pastWeek:
            times = Array(stride(from: now, through: now.addingTimeInterval(-3600 * 24 * 6), by: -3600 * 24))
            xAxisMarks = AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday())
            }
        case .pastMonth:
            times = Array(stride(from: now, through: now.addingTimeInterval(-3600 * 24 * 29), by: -3600 * 24))
            xAxisMarks = AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisValueLabel(format: .dateTime.day().month())
            }
        case .pastYear:
            times = Array(stride(from: now, through: now.addingTimeInterval(-3600 * 24 * 364), by: -3600 * 24 * 30))
            xAxisMarks = AxisMarks(values: .stride(by: .month, count: 3)) { value in
                AxisValueLabel(format: .dateTime.month())
            }
        }
    }
}

private enum TimeOption: String, CaseIterable, Identifiable {
    case past24Hours = "Past 24 Hours"
    case pastWeek = "Past Week"
    case pastMonth = "Past Month"
    case pastYear = "Past Year"
    
    var id: String { self.rawValue }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    let modelData = ModelData(dummy: true)
    return SatelliteAltitudeChart(satellite: modelData.satellites[0])
        .environment(modelData)
}
