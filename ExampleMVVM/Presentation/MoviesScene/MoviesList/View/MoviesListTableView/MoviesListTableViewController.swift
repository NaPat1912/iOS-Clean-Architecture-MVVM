//
//  MoviesListTableViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListTableViewController: UITableViewController {

    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?

    var viewModel: MoviesListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = MoviesListItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
        bind(to: viewModel)
    }

    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.loadingType.observe(on: self) { [weak self] in self?.update(isLoadingNextPage: $0 == .nextPage) }
        viewModel.reloadItems.observe(on: self) { [weak self] _ in self?.reload() }
    }

    func reload() {
        tableView.reloadData()
    }

    func update(isLoadingNextPage: Bool) {
        if isLoadingNextPage {
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = UIActivityIndicatorView(style: .gray)
            nextPageLoadingSpinner?.startAnimating()
            nextPageLoadingSpinner?.isHidden = false
            nextPageLoadingSpinner?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.frame.width, height: 44)
            tableView.tableFooterView = nextPageLoadingSpinner
        } else {
            tableView.tableFooterView = nil
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MoviesListTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListItemCell.reuseIdentifier, for: indexPath) as? MoviesListItemCell else {
            fatalError("Cannot dequeue reusable cell \(MoviesListItemCell.self) with reuseIdentifier: \(MoviesListItemCell.reuseIdentifier)")
        }

        let item = viewModel.item(for: indexPath)
        cell.fill(with: item, posterImagesRepository: posterImagesRepository)

        if indexPath.row == viewModel.numberOfItems(in: indexPath.section) - 1 {
            viewModel.didLoadNextPage()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}
