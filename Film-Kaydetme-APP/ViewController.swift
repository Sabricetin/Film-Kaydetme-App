//
//  ViewController.swift
//  Film-Kaydetme-APP
//
//  Created by Sabri Çetin on 14.05.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
        
    var namArray = [String] ()
    var idArray = [UUID]()
    var selectedFilm = ""
    var selectedFilmId : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //navigasyon barına "artı-işareti" koymak için kullandığımız kod
        
             navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem (barButtonSystemItem:   UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    // Verileri Çekme Komutu
    
  @objc  func getData () {
      
      //Aynı Verileri TableView'a Kaydetememek İçin 1defa Döndürüyor
      
      namArray.removeAll(keepingCapacity: false)
      idArray.removeAll(keepingCapacity: false)
        
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
      
        do {
         let results =  try  context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "filmadi") as? String {
                        self.namArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    //TableView Yeni Data Geldiği Zaman Güncelleme İşlemi
                    self.tableView.reloadData()
                }
            }
        }
        catch {
            print ("error")
        }
    }
    @objc  func addButtonClicked () {
        selectedFilm = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    //TableView Ayarları
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell ()
        var content = cell.defaultContentConfiguration()
        content.text = namArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    //View Controller Arası Segue Yapma
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenFilm = selectedFilm
            destinationVC.chosenFilmId = selectedFilmId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedFilm = namArray[indexPath.row]
        selectedFilmId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    //Core-Data-Delete-silme-İşlemi
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegete = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegete.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row] .uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
    
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                namArray.remove(at: indexPath.row)
                                idArray .remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print ("error!!!")
                                }
                                break
                            }
                        }
                    }
                }
            }
            catch {
                print ("error!!!")
            }
        }
    }
}
