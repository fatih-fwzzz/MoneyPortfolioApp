import Foundation

nonisolated final class PortfolioRepositoryImpl: PortfolioRepository {
    private let dataSource: TransactionDataProviding
    private let dateParser = DateFormatter()
    private let monthSymbols = Calendar.current.shortMonthSymbols

    init(dataSource: TransactionDataProviding) {
        self.dataSource = dataSource
        dateParser.dateFormat = "dd/MM/yyyy"
        dateParser.locale = Locale(identifier: "en_US_POSIX")
    }

    func fetchPortfolio() throws -> Portfolio {
        let sections = try dataSource.loadSections()

        guard
            let donutSection = sections.first(where: { $0.type == "donutChart" })?.donutData,
            let lineSection = sections.first(where: { $0.type == "lineChart" })?.lineData
        else {
            throw TransactionDataLocalDataSource.DataSourceError.invalidFormat
        }

        let allocations = donutSection.map(mapAllocation(_:))
        let totalBalance = allocations.reduce(0) { $0 + $1.nominal }
        let trendPoints = mapTrendPoints(lineSection.month)
        let percentageChange = calculatePercentageChange(from: trendPoints)

        return Portfolio(
            totalBalance: totalBalance,
            percentageChange: percentageChange,
            allocations: allocations,
            monthlyTrends: trendPoints
        )
    }

    private func mapAllocation(_ dto: AllocationDTO) -> AssetAllocation {
        let transactions = dto.data.enumerated().map { index, item in
            let parsedDate = dateParser.date(from: item.trxDate) ?? Date()
            // Spreads generated times so list entries show date and time consistently.
            let dateWithTime = Calendar.current.date(bySettingHour: 9 + (index * 2), minute: 15, second: 0, of: parsedDate) ?? parsedDate
            return Transaction(
                id: UUID(),
                title: normalizedCategoryName(from: dto.label),
                date: dateWithTime,
                amount: item.nominal
            )
        }

        return AssetAllocation(
            category: normalizedCategoryName(from: dto.label),
            percentage: Double(dto.percentage) ?? 0,
            nominal: transactions.reduce(0) { $0 + $1.amount },
            hexColor: colorHex(for: dto.label),
            transactions: transactions.sorted { $0.date > $1.date }
        )
    }

    private func mapTrendPoints(_ points: [Double]) -> [TrendPoint] {
        let trimmed = Array(points.suffix(monthSymbols.count))
        let startIndex = max(monthSymbols.count - trimmed.count, 0)
        let labels = Array(monthSymbols[startIndex...])
        return zip(labels, trimmed).map { month, value in
            TrendPoint(month: month, value: value)
        }
    }

    private func calculatePercentageChange(from trendPoints: [TrendPoint]) -> Double {
        guard let first = trendPoints.first?.value, let last = trendPoints.last?.value, first != 0 else {
            return 0
        }
        return ((last - first) / first) * 100
    }

    private func normalizedCategoryName(from raw: String) -> String {
        switch raw.lowercased() {
        case "qris payment":
            return "QRIS"
        default:
            return raw
        }
    }

    private func colorHex(for category: String) -> String {
        switch category.lowercased() {
        case "tarik tunai":
            return "#F57C00"
        case "qris payment", "qris":
            return "#4DD0C4"
        case "topup gopay":
            return "#CDDC39"
        default:
            return "#8A8A8A"
        }
    }
}

