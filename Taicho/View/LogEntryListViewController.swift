//
//  LogEntryListViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import UIKit

/**
 The base ViewController for viewing, filteirng, and editing log entries. Log entries will have display options.
 */
class LogEntryListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private var logEntries: [LogEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.backgroundColor = .lightGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        //        TaichoContainer.container.logEntryDataManager.createNewLogStartingNow("Hello!", productivityLevel: .high, notes: nil)
        //        TaichoContainer.container.persistenceController.saveContext()
        updateData()
    }
    
    func updateData() {
        logEntries = TaichoContainer.container.logEntryDataManager.getAllLogEntries()
        tableView.reloadData()
    }

}

// MARK: - UITableView

extension LogEntryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let logEntry = logEntries[safe: indexPath.row] else {
            Log.assert("Missing entry for index path: \(indexPath)")
            return UITableViewCell()
        }
        let cell = UITableViewCell()
        cell.textLabel!.text = logEntry.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let logEntry = logEntries[safe: indexPath.row] else {
            Log.assert("Missing entry for index path: \(indexPath)")
            return
        }
        let navigationController = UINavigationController(
            rootViewController: LogEntryDetailViewController(logEntry: logEntry))
        present(navigationController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
