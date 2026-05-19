import Charts
import UIKit

final class AllocationDetailViewController: UIViewController, AllocationDetailView {
    private let presenter: AllocationDetailPresenting

    private let chart = PieChartView()
    private let detailsStack = UIStackView()

    init(presenter: AllocationDetailPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.Colors.offWhite
        configureNavigationBar()
        configureLayout()
        presenter.viewDidLoad()
    }

    func show(viewModel: AllocationDetailViewModel) {
        renderChart(items: viewModel.items, totalText: viewModel.totalAllocationText, selectedIndex: viewModel.selectedIndex)
        renderList(items: viewModel.items)
    }

    // MARK: - Navigation

    private func configureNavigationBar() {
        title = "Asset Allocation"
        navigationController?.navigationBar.tintColor = AppTheme.Colors.primaryOrange
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: AppTheme.Colors.primaryOrange,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
    }

    // MARK: - Layout

    private func configureLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        content.addArrangedSubview(makeChartCard())

        let sectionLabel = UILabel()
        sectionLabel.text = "Allocation Details"
        sectionLabel.font = AppTheme.Fonts.headlineMedium()
        content.addArrangedSubview(sectionLabel)

        detailsStack.axis = .vertical
        detailsStack.spacing = 12
        content.addArrangedSubview(detailsStack)
    }

    private func makeChartCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = AppTheme.Radius.standard
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.usePercentValuesEnabled = true
        chart.legend.enabled = false
        chart.rotationEnabled = false
        chart.chartDescription.enabled = false
        chart.holeRadiusPercent = 0.58
        chart.transparentCircleRadiusPercent = 0.61
        chart.drawEntryLabelsEnabled = false
        chart.centerAttributedText = NSAttributedString(string: "")

        let hintLabel = UILabel()
        hintLabel.text = "Tap on any segment to view detailed\ntransaction history."
        hintLabel.font = AppTheme.Fonts.bodyRegular()
        hintLabel.textColor = AppTheme.Colors.mutedText
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(chart)
        card.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            chart.heightAnchor.constraint(equalToConstant: 280),

            hintLabel.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 12),
            hintLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            hintLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            hintLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    // MARK: - Render

    private func renderChart(items: [AllocationDetailViewModel.Item], totalText: String, selectedIndex: Int) {
        let entries = items.map {
            PieChartDataEntry(
                value: max(0.1, Double($0.percentageText.replacingOccurrences(of: "%", with: "")) ?? 0),
                label: $0.category
            )
        }
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = items.map { UIColor(hex: $0.hexColor) }
        dataSet.sliceSpace = 2
        dataSet.selectionShift = 10
        dataSet.drawValuesEnabled = false

        chart.data = PieChartData(dataSet: dataSet)
        chart.highlightValue(x: Double(selectedIndex), dataSetIndex: 0)

        let centerText = NSMutableAttributedString(
            string: totalText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .bold),
                .foregroundColor: UIColor.black
            ]
        )
        centerText.append(NSAttributedString(
            string: "\nTotal Assets",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: AppTheme.Colors.mutedText
            ]
        ))
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        centerText.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: centerText.length))
        chart.centerAttributedText = centerText
    }

    private func renderList(items: [AllocationDetailViewModel.Item]) {
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.backgroundColor = .white
            button.layer.cornerRadius = AppTheme.Radius.standard
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.05
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 4
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 80).isActive = true

            let swatch = UIView()
            swatch.backgroundColor = UIColor(hex: item.hexColor).withAlphaComponent(0.18)
            swatch.layer.cornerRadius = 14
            swatch.translatesAutoresizingMaskIntoConstraints = false
            swatch.widthAnchor.constraint(equalToConstant: 48).isActive = true
            swatch.heightAnchor.constraint(equalToConstant: 48).isActive = true

            let dot = UIView()
            dot.backgroundColor = UIColor(hex: item.hexColor)
            dot.layer.cornerRadius = 8
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 16).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 16).isActive = true
            swatch.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.centerXAnchor.constraint(equalTo: swatch.centerXAnchor),
                dot.centerYAnchor.constraint(equalTo: swatch.centerYAnchor)
            ])

            let titleLabel = UILabel()
            titleLabel.text = item.category
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.textColor = .black

            let subtitleLabel = UILabel()
            subtitleLabel.text = "\(item.percentageText) • \(item.nominalText)"
            subtitleLabel.font = AppTheme.Fonts.bodyRegular()
            subtitleLabel.textColor = AppTheme.Colors.mutedText

            let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            textStack.axis = .vertical
            textStack.spacing = 3

            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = UIColor(white: 0.7, alpha: 1)
            chevron.translatesAutoresizingMaskIntoConstraints = false

            let row = UIStackView(arrangedSubviews: [swatch, textStack, UIView(), chevron])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 12
            row.isUserInteractionEnabled = false
            row.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(row)

            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
                row.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
                row.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
                row.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16)
            ])

            detailsStack.addArrangedSubview(button)
        }
    }

    @objc
    private func itemTapped(_ sender: UIButton) {
        presenter.didTapAllocation(at: sender.tag)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
