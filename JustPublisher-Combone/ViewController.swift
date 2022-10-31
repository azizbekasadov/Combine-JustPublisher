//
//  ViewController.swift
//  JustPublisher-Combone
//
//  Created by Azizbek Asadov on 31/10/22.
//

import UIKit
import Combine

struct User: Codable {
    var name: String
}

class ViewController: UIViewController {

    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    var observer: AnyCancellable?
    
    private var data: [User] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        observer = fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.data = data
                self?.tableView.reloadData()
            })
            
    }


    
    func fetchUsers() -> AnyPublisher<[User], Never> {
        guard let url = self.url else {
            return Just([]).eraseToAnyPublisher() // return only once, a single time
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [User].self, decoder: JSONDecoder())
            .catch { _ in
                Just([])
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.data[indexPath.row].name
        return cell
    }
}
