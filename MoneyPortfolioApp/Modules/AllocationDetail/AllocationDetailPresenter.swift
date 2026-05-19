import Foundation

final class AllocationDetailPresenter: AllocationDetailPresenting {
    weak var view: AllocationDetailView?

    private let interactor: AllocationDetailInteracting
    private let router: AllocationDetailRouting
    private var selectedIndex: Int
    private var portfolio: Portfolio

    init(interactor: AllocationDetailInteracting, router: AllocationDetailRouting, selectedIndex: Int) {
        self.interactor = interactor
        self.router = router
        self.selectedIndex = selectedIndex
        self.portfolio = interactor.getPortfolio()
    }

    func viewDidLoad() {
        portfolio = interactor.getPortfolio()
        let items = portfolio.allocations.map {
            AllocationDetailViewModel.Item(
                category: $0.category,
                percentageText: String(format: "%.1f%%", $0.percentage),
                nominalText: AppFormatters.currency.rupiah($0.nominal),
                hexColor: $0.hexColor
            )
        }

        let viewModel = AllocationDetailViewModel(
            totalAllocationText: AppFormatters.compactCurrency.rupiah(portfolio.totalBalance),
            items: items,
            selectedIndex: selectedIndex
        )

        view?.show(viewModel: viewModel)
    }

    func didTapAllocation(at index: Int) {
        guard portfolio.allocations.indices.contains(index) else { return }
        selectedIndex = index
        router.showTransactionHistory(for: portfolio.allocations[index])
    }
}

