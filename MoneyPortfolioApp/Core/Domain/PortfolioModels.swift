import Foundation

struct Portfolio {
    let totalBalance: Double
    let percentageChange: Double
    let allocations: [AssetAllocation]
    let monthlyTrends: [TrendPoint]
}

struct AssetAllocation {
    let category: String
    let percentage: Double
    let nominal: Double
    let hexColor: String
    let transactions: [Transaction]
}

struct Transaction {
    let id: UUID
    let title: String
    let date: Date
    let amount: Double
}

struct TrendPoint {
    let month: String
    let value: Double
}

