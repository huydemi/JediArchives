/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class CharacterDetailViewController: UITableViewController {

  let characterID: String
  let dataSource = ListDataSource()

  init(characterID: String) {
    self.characterID = characterID
    super.init(style: .grouped)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    loadCharacter()
  }

  func configure() {
    applyDarkStyle()
    dataSource.configure(with: tableView)
  }
}

// MARK: Table View
extension CharacterDetailViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch dataSource.sections[indexPath.section] {
    case .references(_, let models):
      let model = models[indexPath.row]
      let detailVC = FilmDetailViewController(filmID: model.id)
      navigationController?.pushViewController(detailVC, animated: true)
    default:
      break
    }
  }
}

// MARK: Data
extension CharacterDetailViewController {

  func loadCharacter() {
    
    let query = CharacterDetailQuery(id: characterID)
    Apollo.shared.client.fetch(query: query) { (result, error) in
      
      if let character = result?.data?.person {
        self.navigationItem.title = character.name ?? ""
        
        let infoItems: [InfoItem] = [
          InfoItem(label: NSLocalizedString("Name", comment: ""),
                   value: character.name ?? "NA"),
          InfoItem(label: NSLocalizedString("Birth Year", comment: ""),
                   value: character.birthYear ?? "NA"),
          InfoItem(label: NSLocalizedString("Eye Color", comment: ""),
                   value: character.eyeColor ?? "NA"),
          InfoItem(label: NSLocalizedString("Gender", comment: ""),
                   value: character.gender ?? "NA"),
          InfoItem(label: NSLocalizedString("Hair Color", comment: ""),
                   value: character.hairColor ?? "NA"),
          InfoItem(label: NSLocalizedString("Skin Color", comment: ""),
                   value: character.skinColor ?? "NA"),
          InfoItem(label: NSLocalizedString("Home World", comment: ""),
                   value: character.homeworld?.name ?? "NA")
        ]
        
        var sections: [Section] = [
          .info(title: NSLocalizedString("Info", comment: ""), models: infoItems)
        ]
        
        let filmItems = character.filmConnection?.films?.compactMap({$0})
          .map({RefItem(film: $0.fragments.listFilmFragment)})
        if let filmItems = filmItems, filmItems.count > 0 {
          sections.append(.references(title: NSLocalizedString("Appears In", comment: ""),
                                      models: filmItems))
        }
        
        self.dataSource.sections = sections
        self.tableView.reloadData()
      } else if let error = error {
        print("Error loading data \(error)")
      }
    }
  }
}
