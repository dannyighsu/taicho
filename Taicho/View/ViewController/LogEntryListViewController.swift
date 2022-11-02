//
//  LogEntryListViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import UIKit
import Combine

/**
 The base ViewController for viewing, filteirng, and editing log entries. Log entries will have display options.
 */
class LogEntryListViewController: UIViewController {

    // MARK: - Constants

    private static let title = "Log History"
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    
    private var viewModels: [LogEntryListCellViewModel] = []

    /**
     The subscriber for log entry insertions. Will cause an update
     to the table view when log entries are added.
     */
    private var logEntriesInsertedReceiver: AnyCancellable?

    /**
     The subscriber for log entry removals. Will cause an update to the table view
     when log entries are removed, if necessary.
     */
    private var logEntriesDeletedReceiver: AnyCancellable?

    /**
     The subscriber listening to updates for individual log entries.
     */
    private var logEntryObjectsReceiver: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = LogEntryListViewController.title
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogEntryListCell.self, forCellReuseIdentifier: LogEntryListCell.reuseIdentifier)
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        logEntriesInsertedReceiver = TaichoContainer.container.logEntryDataManager.objectInsertedPublisher.sink(receiveValue: { [weak self] logEntries in
            logEntries.forEach {
                self?.viewModels.append(LogEntryListCellViewModel($0))
            }
            self?.updateData()
        })
        logEntriesDeletedReceiver = TaichoContainer.container.logEntryDataManager.objectDeletedPublisher.sink(receiveValue: { [weak self] logEntries in
            self?.viewModels.removeAll(where: { viewModel in
                logEntries.contains { $0.objectID == viewModel.logEntry.objectID }
            })
            self?.updateData()
        })

        logEntryObjectsReceiver = TaichoContainer.container.logEntryDataManager.objectUpdatePublisher.sink(receiveValue: { [weak self] logEntries in
            self?.viewModels.forEach({ viewModel in
                if logEntries.contains(where: { $0.objectID == viewModel.logEntry.objectID }) {
                    viewModel.reload()
                }
            })
            self?.updateData()
        })

        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewModels(with: TaichoContainer.container.logEntryDataManager.getAll())
    }
    
    private func updateData() {
        tableView.reloadData()
    }
    
    private func loadViewModels(with logEntries: [LogEntry]) {
        viewModels = logEntries.map { LogEntryListCellViewModel($0) }
    }

}

// MARK: - UITableView

extension LogEntryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModels[safe: indexPath.row] else {
            Log.assert("Missing view model for index path: \(indexPath)")
            return 0
        }
        return LogEntryListCell.requiredHeight(for: viewModel.logEntry)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModels[safe: indexPath.row] else {
            Log.assert("Missing view model for index path: \(indexPath)")
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogEntryListCell.reuseIdentifier) as? LogEntryListCell else {
            Log.assert("Invalid cell type dequeued")
            return UITableViewCell()
        }

        cell.load(viewModel)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModels[safe: indexPath.row] else {
            Log.assert("Missing view model for index path: \(indexPath)")
            return
        }
        let navigationController = UINavigationController(
            rootViewController: LogEntryDetailViewController(logEntry: viewModel.logEntry, context: .edit))
        present(navigationController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
