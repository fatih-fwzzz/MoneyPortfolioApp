import UIKit

final class TransactionHistoryViewController: UIViewController, TransactionHistoryView {
    private let presenter: TransactionHistoryPresenting
    private var items: [TransactionHistoryViewModel.Item] = []

    private let headerCard = UIView()
    private let totalSpentLabel = UILabel()
    private let iconTile = UIView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(presenter: TransactionHistoryPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.Colors.offWhite
        configureLayout()
        presenter.viewDidLoad()
    }

    func show(viewModel: TransactionHistoryViewModel) {
        title = "\(viewModel.categoryTitle) Detail"
        totalSpentLabel.text = viewModel.totalSpentText
        iconTile.backgroundColor = UIColor(hex: viewModel.hexColor).withAlphaComponent(0.7)
        items = viewModel.items
        tableView.reloadData()
    }

    private func configureLayout() {
        headerCard.backgroundColor = .white
        headerCard.layer.cornerRadius = AppTheme.Radius.standard
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        iconTile.layer.cornerRadius = AppTheme.Radius.standard
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "wallet.pass"))
        icon.tintColor = UIColor.white
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconTile.addSubview(icon)

        let spentTitle = UILabel()
        spentTitle.text = "Total spent"
        spentTitle.font = AppTheme.Fonts.bodyRegular()
        spentTitle.textColor = AppTheme.Colors.mutedText
        spentTitle.translatesAutoresizingMaskIntoConstraints = false

        totalSpentLabel.font = AppTheme.Fonts.displayBold()
        totalSpentLabel.translatesAutoresizingMaskIntoConstraints = false

        [headerCard, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        headerCard.addSubview(iconTile)
        headerCard.addSubview(spentTitle)
        headerCard.addSubview(totalSpentLabel)

        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.rowHeight = 82
        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerCard.heightAnchor.constraint(equalToConstant: 170),

            iconTile.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 20),
            iconTile.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            iconTile.widthAnchor.constraint(equalToConstant: 64),
            iconTile.heightAnchor.constraint(equalToConstant: 64),
            icon.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),

            spentTitle.topAnchor.constraint(equalTo: iconTile.bottomAnchor, constant: 12),
            spentTitle.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),

            totalSpentLabel.topAnchor.constraint(equalTo: spentTitle.bottomAnchor, constant: 6),
            totalSpentLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension TransactionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseIdentifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

private final class TransactionCell: UITableViewCell {
    static let reuseIdentifier = "TransactionCell"

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateLabel.font = AppTheme.Fonts.bodyRegular()
        dateLabel.textColor = AppTheme.Colors.mutedText
        amountLabel.font = .systemFont(ofSize: 16, weight: .bold)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [textStack, UIView(), amountLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: TransactionHistoryViewModel.Item) {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.dateText
        amountLabel.text = viewModel.amountText
    }
}

