import Foundation

final class DashboardPresenter: DashboardPresenting {
    weak var view: DashboardView?

    private let interactor: DashboardInteracting
    private let router: DashboardRouting
    private var portfolio: Portfolio?

    init(interactor: DashboardInteracting, router: DashboardRouting) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        do {
            let portfolio = try interactor.fetchPortfolio()
            self.portfolio = portfolio
            view?.show(viewModel: makeViewModel(from: portfolio))
        } catch {
            view?.show(errorMessage: error.localizedDescription)
        }
    }

    func didTapAllocation(at index: Int) {
        guard let portfolio, portfolio.allocations.indices.contains(index) else { return }
        router.showAllocationDetail(portfolio: portfolio, selectedIndex: index)
    }

    private func makeViewModel(from portfolio: Portfolio) -> DashboardViewModel {
        let allocationItems = portfolio.allocations.map { allocation in
            DashboardViewModel.AllocationItem(
                category: allocation.category,
                percentageText: String(format: "%.1f%%", allocation.percentage),
                nominalText: AppFormatters.currency.rupiah(allocation.nominal),
                hexColor: allocation.hexColor
            )
        }

        return DashboardViewModel(
            totalBalanceText: AppFormatters.currency.rupiah(portfolio.totalBalance),
            percentageChangeText: String(format: "%+.1f%%", portfolio.percentageChange),
            allocations: allocationItems,
            monthlyTrendMonths: portfolio.monthlyTrends.map(\.month),
            monthlyTrendValues: portfolio.monthlyTrends.map(\.value)
        )
    }
}

