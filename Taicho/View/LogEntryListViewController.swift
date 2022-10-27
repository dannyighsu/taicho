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
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    
    @Published private var viewModels: [LogEntryListCellViewModel] = []
    /**
     The reactive stream for the viewModels array. Will cause an update
     to the table view with the array membership is updated.
     */
    private var viewModelStream: AnyCancellable?

    /**
     The subscriber listening to updates for individual log entries.
     */
    private var viewModelReceiver: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.backgroundColor = .lightGray
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

        viewModelStream = $viewModels.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.updateData()
        }

        viewModelReceiver = TaichoContainer.container.logEntryDataManager.publisher.sink { [weak self] logEntry in
            self?.reloadCell(with: logEntry)
        }

        //        TaichoContainer.container.logEntryDataManager.createNewLogStartingNow("Hello!", productivityLevel: .high, notes: nil)
        //        TaichoContainer.container.persistenceController.saveContext()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewModels(with: TaichoContainer.container.logEntryDataManager.getAll())
    }
    
    private func updateData() {
        tableView.reloadData()
    }

    private func reloadCell(with logEntry: LogEntry) {
        guard let viewModel = viewModels.first(where: { viewModel in
            viewModel.logEntry.objectID == logEntry.objectID
        }) else {
            return
        }
        viewModel.logEntry = logEntry
        updateData()
    }
    
    private func loadViewModels(with logEntries: [LogEntry]) {
        viewModels = logEntries.map { LogEntryListCellViewModel($0) }
        viewModels.forEach { viewModel in
            viewModel.delegate = self
        }
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
            rootViewController: LogEntryDetailViewController(logEntry: viewModel.logEntry))
        present(navigationController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - LogEntryListCellViewModelDelegate

extension LogEntryListViewController: LogEntryListCellViewModelDelegate {
    
    func logEntryDidUpdate(_ logEntry: LogEntry) {
        updateData()
    }
    
}
