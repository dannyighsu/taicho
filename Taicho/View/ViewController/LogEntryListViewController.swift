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

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogEntryListCell.self, forCellReuseIdentifier: LogEntryListCell.reuseIdentifier)
        tableView.register(LogEntryListSearchHeaderView.self, forHeaderFooterViewReuseIdentifier: LogEntryListSearchHeaderView.reuseIdentifier)
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
        configureNavigationItem()
        loadViewModels(with: TaichoContainer.container.logEntryDataManager.getAll())
    }

    private func configureNavigationItem() {
        navigationItem.title = LogEntryListViewController.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped))
    }
    
    private func updateData() {
        tableView.reloadData()
    }
    
    private func loadViewModels(with logEntries: [LogEntry]) {
        viewModels = logEntries.map { LogEntryListCellViewModel($0) }
        updateData()
    }

    @objc
    private func shareTapped() {
        let dataHeaderRow = "name,time,timezone,productivity_level,notes"
        let allLogsAsCSVRow = TaichoContainer.container.logEntryDataManager.getAll().map { logEntry -> String in
            var fieldString = "\(logEntry.name),\(DateUtils.getDisplayFormat(logEntry.time)),\(logEntry.timezone.identifier),\(logEntry.productivityLevel)"
            if let notes = logEntry.notes {
                fieldString += "," + notes
            }
            return fieldString
        }
        let csvString = ([dataHeaderRow] + allLogsAsCSVRow).joined(separator: "\n")
        let activityController = UIActivityViewController(activityItems: [csvString], applicationActivities: nil)
        present(activityController, animated: true)
    }

}

// MARK: - LogEntryListSearchHeaderViewDelegate

extension LogEntryListViewController: LogEntryListSearchHeaderViewDelegate {

    func dateWasSelected(_ date: Date, searchText: String?) {
        loadViewModels(with: TaichoContainer.container.logEntryDataManager.search(name: searchText, date: date))
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadViewModels(with: TaichoContainer.container.logEntryDataManager.search(name: searchBar.text))
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }

}

// MARK: - UITableView

extension LogEntryListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LogEntryListSearchHeaderView.reuseIdentifier) as? LogEntryListSearchHeaderView else {
            Log.assert("Failed to dequeue header view at section \(section)")
            return nil
        }
        headerView.delegate = self
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LogEntryListSearchHeaderView.height
    }
    
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let confirmationDialog = UIUtils.getConfirmationAlert("Delete this log?")
        confirmationDialog.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { [weak self, weak confirmationDialog] _ in
                self?.deleteLog(at: indexPath)
                confirmationDialog?.dismiss(animated: true)
            }))
        confirmationDialog.addAction(UIUtils.getDismissAction(confirmationDialog))
        present(confirmationDialog, animated: true)
    }

    private func deleteLog(at indexPath: IndexPath) {
        guard let logEntry = viewModels[safe: indexPath.row]?.logEntry else {
            Log.assert("Failed to find log entry to delete at index path \(indexPath)")
            return
        }
        viewModels.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        TaichoContainer.container.logEntryDataManager.delete(logEntry)
    }
    
}
