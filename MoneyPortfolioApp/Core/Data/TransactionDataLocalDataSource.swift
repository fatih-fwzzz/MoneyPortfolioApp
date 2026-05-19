import Foundation

protocol TransactionDataProviding {
    func loadSections() throws -> [TransactionSectionDTO]
}

final class TransactionDataLocalDataSource: TransactionDataProviding {
    enum DataSourceError: LocalizedError {
        case fileNotFound
        case invalidFormat

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "transaction_data.json was not found in bundle resources."
            case .invalidFormat:
                return "transaction_data.json format is invalid."
            }
        }
    }

    func loadSections() throws -> [TransactionSectionDTO] {
        guard let url = Bundle.main.url(forResource: "transaction_data", withExtension: "json") else {
            throw DataSourceError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([TransactionSectionDTO].self, from: data)
    }
}

struct TransactionSectionDTO: Decodable {
    let type: String
    let donutData: [AllocationDTO]?
    let lineData: LineChartDTO?

    enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    init(type: String, donutData: [AllocationDTO]?, lineData: LineChartDTO?) {
        self.type = type
        self.donutData = donutData
        self.lineData = lineData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        if let allocations = try? container.decode([AllocationDTO].self, forKey: .data) {
            donutData = allocations
            lineData = nil
            return
        }

        if let line = try? container.decode(LineChartDTO.self, forKey: .data) {
            donutData = nil
            lineData = line
            return
        }

        throw TransactionDataLocalDataSource.DataSourceError.invalidFormat
    }
}

struct AllocationDTO: Decodable {
    let label: String
    let percentage: String
    let data: [TransactionDTO]
}

struct TransactionDTO: Decodable {
    let trxDate: String
    let nominal: Double

    enum CodingKeys: String, CodingKey {
        case trxDate = "trx_date"
        case nominal
    }
}

struct LineChartDTO: Decodable {
    let month: [Double]
}

