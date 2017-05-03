/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class SearchViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  lazy var duckDuckGo = DuckDuckGo()
  
  var searchTerms = [String]()
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func unwindToRootViewController(_ segue: UIStoryboardSegue) {}
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    performSearchForTerm(searchBar.text)
  }
  
  func saveSearchTerm(_ term: String) {
    if self.searchTerms.contains(term) {
      return
    }
    
    searchTerms.insert(term, at: 0)
    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
  }
  
  func performSearchForTerm(_ term: String?) {
    guard let term = term else { return }

    activityIndicator.startAnimating()
    
    duckDuckGo.performSearch(searchTerm: term) { definition in
      self.activityIndicator.stopAnimating()
      
      if let definition = definition {
        self.saveSearchTerm(term)
        
        self.performSegue(withIdentifier: "DefinitionSegue", sender: DefinitionSegueContext(definition: definition))
      } else {
        self.showNoDefinitionAlertForTerm(term)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let context = sender as? DefinitionSegueContext, segue.identifier == "DefinitionSegue" {
      let vc = segue.destination as! DefinitionViewController
      vc.definition = context.definition
    }
  }
  
  func showNoDefinitionAlertForTerm(_ term: String) {
    let alertController = UIAlertController(title: "Huh...", message: "No definition could be found for \(term). Try searching for something else?", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchTerms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.textLabel!.text = searchTerms[indexPath.row]
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSearchForTerm(searchTerms[indexPath.row])
  }
}
