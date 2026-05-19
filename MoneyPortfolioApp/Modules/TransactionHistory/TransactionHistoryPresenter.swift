import Foundation

final class TransactionHistoryPresenter: TransactionHistoryPresenting {
    weak var view: TransactionHistoryView?

    private let interactor: TransactionHistoryInteracting

    init(interactor: TransactionHistoryInteracting) {
        self.interactor = interactor
    }

    func viewDidLoad() {
        let allocation = interactor.getAllocation()
        let items = allocation.transactions.map {
            TransactionHistoryViewModel.Item(
                title: $0.title,
                dateText: AppFormatters.isoDateTime.string(from: $0.date),
                amountText: AppFormatters.currency.rupiah($0.amount)
            )
        }

        let viewModel = TransactionHistoryViewModel(
            categoryTitle: allocation.category,
            totalSpentText: AppFormatters.currency.rupiah(allocation.nominal),
            items: items,
            hexColor: allocation.hexColor
        )
        view?.show(viewModel: viewModel)
    }
}

