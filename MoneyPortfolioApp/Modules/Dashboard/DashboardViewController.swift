import Charts
import UIKit

final class DashboardViewController: UIViewController, DashboardView {
    private enum TrendRange {
        case sixMonths
        case oneYear
    }

    private let presenter: DashboardPresenting

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let totalBalanceCard = UIView()
    private let totalBalanceLabel = UILabel()
    private let percentagePill = PaddedLabel()
    private let allocationCard = UIView()
    private let allocationChart = PieChartView()
    private let allocationLegendStack = UIStackView()
    private let monthlyCard = UIView()
    private let monthlyChart = LineChartView()
    private let trendRangeControl = UISegmentedControl(items: ["6 Months", "1 Year"])
    private var allocationButtons: [UIButton] = []
    private var allTrendMonths: [String] = []
    private var allTrendValues: [Double] = []
    private var selectedTrendRange: TrendRange = .sixMonths

    init(presenter: DashboardPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Portfolio Money"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = AppTheme.Colors.offWhite
        configureLayout()
        configureStaticStyle()
        presenter.viewDidLoad()
    }

    func show(viewModel: DashboardViewModel) {
        totalBalanceLabel.text = viewModel.totalBalanceText
        percentagePill.text = "↗ \(viewModel.percentageChangeText)"
        renderAllocationChart(items: viewModel.allocations)
        renderAllocationLegend(items: viewModel.allocations)
        allTrendMonths = viewModel.monthlyTrendMonths
        allTrendValues = viewModel.monthlyTrendValues
        renderSelectedMonthlyTrend()
    }

    func show(errorMessage: String) {
        let alert = UIAlertController(title: "Failed to load", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        [totalBalanceCard, allocationCard, monthlyCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview($0)
        }

        totalBalanceCard.heightAnchor.constraint(equalToConstant: 190).isActive = true
        allocationCard.heightAnchor.constraint(equalToConstant: 270).isActive = true
        monthlyCard.heightAnchor.constraint(equalToConstant: 280).isActive = true
    }

    private func configureStaticStyle() {
        configureTotalBalanceCard()
        configureAllocationCard()
        configureMonthlyCard()
    }

    private func configureTotalBalanceCard() {
        totalBalanceCard.backgroundColor = AppTheme.Colors.primaryOrange
        totalBalanceCard.layer.cornerRadius = AppTheme.Radius.large

        let titleLabel = UILabel()
        titleLabel.text = "Total Balance"
        titleLabel.textColor = .white
        titleLabel.font = AppTheme.Fonts.bodyRegular()

        totalBalanceLabel.textColor = .white
        totalBalanceLabel.font = AppTheme.Fonts.displayBold()

        percentagePill.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        percentagePill.textColor = .white
        percentagePill.font = AppTheme.Fonts.bodyRegular()
        percentagePill.layer.cornerRadius = 18
        percentagePill.layer.masksToBounds = true
        percentagePill.textAlignment = .center

        let actionStack = UIStackView()
        actionStack.axis = .horizontal
        actionStack.spacing = 12
        actionStack.distribution = .fillEqually

        let topUpButton = makeActionButton(title: "Top Up", systemImageName: "plus", background: .white, textColor: AppTheme.Colors.primaryOrange)
        let transferButton = makeActionButton(title: "Transfer", systemImageName: "paperplane", background: .white, textColor: AppTheme.Colors.primaryOrange)
        actionStack.addArrangedSubview(topUpButton)
        actionStack.addArrangedSubview(transferButton)

        let topRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), percentagePill])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.translatesAutoresizingMaskIntoConstraints = false

        [totalBalanceLabel, actionStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        totalBalanceCard.addSubview(topRow)
        totalBalanceCard.addSubview(totalBalanceLabel)
        totalBalanceCard.addSubview(actionStack)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: totalBalanceCard.topAnchor, constant: 20),
            topRow.leadingAnchor.constraint(equalTo: totalBalanceCard.leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: totalBalanceCard.trailingAnchor, constant: -20),

            totalBalanceLabel.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 16),
            totalBalanceLabel.leadingAnchor.constraint(equalTo: totalBalanceCard.leadingAnchor, constant: 20),

            actionStack.leadingAnchor.constraint(equalTo: totalBalanceCard.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: totalBalanceCard.trailingAnchor, constant: -20),
            actionStack.bottomAnchor.constraint(equalTo: totalBalanceCard.bottomAnchor, constant: -18),
            actionStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureAllocationCard() {
        allocationCard.backgroundColor = AppTheme.Colors.cardBackground
        allocationCard.layer.cornerRadius = AppTheme.Radius.standard

        let title = UILabel()
        title.text = "Asset Allocation"
        title.font = AppTheme.Fonts.headlineMedium()
        title.textColor = .black

        allocationChart.translatesAutoresizingMaskIntoConstraints = false
        allocationChart.usePercentValuesEnabled = true
        allocationChart.legend.enabled = false
        allocationChart.holeRadiusPercent = 0.62
        allocationChart.transparentCircleRadiusPercent = 0.64
        allocationChart.drawEntryLabelsEnabled = false
        allocationChart.highlightPerTapEnabled = false
        allocationChart.chartDescription.enabled = false
        allocationChart.rotationEnabled = false

        allocationLegendStack.axis = .vertical
        allocationLegendStack.spacing = 10
        allocationLegendStack.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [allocationChart, allocationLegendStack])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .fill
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false

        [title, row].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            allocationCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: allocationCard.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: allocationCard.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: allocationCard.trailingAnchor, constant: -20),

            row.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: allocationCard.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: allocationCard.trailingAnchor, constant: -12),
            row.bottomAnchor.constraint(equalTo: allocationCard.bottomAnchor, constant: -12)
        ])
    }

    private func configureMonthlyCard() {
        monthlyCard.backgroundColor = AppTheme.Colors.cardBackground
        monthlyCard.layer.cornerRadius = AppTheme.Radius.standard

        let title = UILabel()
        title.text = "Monthly Trend"
        title.font = AppTheme.Fonts.headlineMedium()
        title.textColor = .black
        title.translatesAutoresizingMaskIntoConstraints = false

        trendRangeControl.selectedSegmentIndex = 0
        trendRangeControl.backgroundColor = UIColor(hex: "#F8E9DC")
        trendRangeControl.selectedSegmentTintColor = AppTheme.Colors.primaryOrange
        trendRangeControl.setTitleTextAttributes([.font: AppTheme.Fonts.bodyRegular(), .foregroundColor: UIColor.darkGray], for: .normal)
        trendRangeControl.setTitleTextAttributes([.font: AppTheme.Fonts.bodyRegular(), .foregroundColor: UIColor.white], for: .selected)
        trendRangeControl.addTarget(self, action: #selector(trendRangeChanged(_:)), for: .valueChanged)
        trendRangeControl.translatesAutoresizingMaskIntoConstraints = false

        monthlyChart.translatesAutoresizingMaskIntoConstraints = false
        monthlyChart.chartDescription.enabled = false
        monthlyChart.rightAxis.enabled = false
        monthlyChart.legend.enabled = false
        monthlyChart.dragEnabled = false
        monthlyChart.setScaleEnabled(false)
        monthlyChart.pinchZoomEnabled = false
        monthlyChart.xAxis.labelPosition = .bottom

        monthlyCard.addSubview(title)
        monthlyCard.addSubview(trendRangeControl)
        monthlyCard.addSubview(monthlyChart)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: monthlyCard.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: monthlyCard.leadingAnchor, constant: 20),

            trendRangeControl.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            trendRangeControl.trailingAnchor.constraint(equalTo: monthlyCard.trailingAnchor, constant: -20),
            trendRangeControl.widthAnchor.constraint(equalToConstant: 160),
            trendRangeControl.heightAnchor.constraint(equalToConstant: 34),

            monthlyChart.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            monthlyChart.leadingAnchor.constraint(equalTo: monthlyCard.leadingAnchor, constant: 8),
            monthlyChart.trailingAnchor.constraint(equalTo: monthlyCard.trailingAnchor, constant: -8),
            monthlyChart.bottomAnchor.constraint(equalTo: monthlyCard.bottomAnchor, constant: -12)
        ])
    }

    private func renderAllocationChart(items: [DashboardViewModel.AllocationItem]) {
        let entries = items.map { PieChartDataEntry(value: max(0.1, Double($0.percentageText.replacingOccurrences(of: "%", with: "")) ?? 0), label: $0.category) }
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = items.map { UIColor(hex: $0.hexColor) }
        dataSet.sliceSpace = 2
        dataSet.drawValuesEnabled = false
        allocationChart.data = PieChartData(dataSet: dataSet)
    }

    private func renderAllocationLegend(items: [DashboardViewModel.AllocationItem]) {
        allocationLegendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        allocationButtons = []

        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.addTarget(self, action: #selector(allocationTapped(_:)), for: .touchUpInside)
            button.contentHorizontalAlignment = .left

            let dotColor = UIColor(hex: item.hexColor)
            let title = NSMutableAttributedString(
                string: "● ",
                attributes: [.foregroundColor: dotColor, .font: AppTheme.Fonts.bodyRegular()]
            )
            title.append(NSAttributedString(
                string: "\(item.category)  \(item.percentageText)",
                attributes: [.foregroundColor: UIColor.black, .font: AppTheme.Fonts.bodyRegular()]
            ))
            button.setAttributedTitle(title, for: .normal)
            allocationButtons.append(button)
            allocationLegendStack.addArrangedSubview(button)
        }
    }

    private func renderMonthlyTrend(months: [String], values: [Double]) {
        let entries = values.enumerated().map { ChartDataEntry(x: Double($0.offset), y: $0.element) }
        let set = LineChartDataSet(entries: entries)
        set.colors = [AppTheme.Colors.primaryOrange]
        set.circleColors = [AppTheme.Colors.primaryOrange]
        set.lineWidth = 2.5
        set.circleRadius = 4
        set.drawCircleHoleEnabled = true
        set.circleHoleRadius = 2
        set.drawFilledEnabled = true
        set.fillColor = AppTheme.Colors.primaryOrange
        set.fillAlpha = 0.2
        set.mode = LineChartDataSet.Mode.cubicBezier
        set.valueTextColor = UIColor.clear
        monthlyChart.data = LineChartData(dataSet: set)
        monthlyChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        monthlyChart.xAxis.granularity = 1
    }

    private func renderSelectedMonthlyTrend() {
        let months: [String]
        let values: [Double]

        switch selectedTrendRange {
        case .sixMonths:
            months = Array(allTrendMonths.suffix(6))
            values = Array(allTrendValues.suffix(6))
        case .oneYear:
            months = allTrendMonths
            values = allTrendValues
        }

        renderMonthlyTrend(months: months, values: values)
    }

    private func makeActionButton(title: String, systemImageName: String, background: UIColor, textColor: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: systemImageName)
        config.imagePadding = 8
        config.baseBackgroundColor = background
        config.baseForegroundColor = textColor
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        
        return button
    }

    @objc
    private func allocationTapped(_ sender: UIButton) {
        presenter.didTapAllocation(at: sender.tag)
    }

    @objc
    private func trendRangeChanged(_ sender: UISegmentedControl) {
        selectedTrendRange = sender.selectedSegmentIndex == 0 ? .sixMonths : .oneYear
        renderSelectedMonthlyTrend()
    }
}

class PaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: insets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom)
    }
}
