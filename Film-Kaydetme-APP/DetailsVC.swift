//
//  DetailsVC.swift
//  Film-Kaydetme-APP
//
//  Created by Sabri Çetin on 14.05.2024.
//

import UIKit
import PhotosUI
import CoreData

class DetailsVC: UIViewController , UINavigationControllerDelegate , PHPickerViewControllerDelegate  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var konuText: UITextField!
    @IBOutlet weak var sureText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenFilm = ""
    var chosenFilmId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenFilm != "" {
            
            //buton'un tıklanıp tıklanmamasını sağlar
            saveButton.isEnabled = false
            
            //CoreData'dan Veri Çekip Göstermek
            
            let appDelegete = UIApplication.shared.delegate as! AppDelegate
            let context  = appDelegete.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idStiring  = chosenFilmId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idStiring!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "filmadi") as? String {
                            nameText.text = name
                        }
                        if let konu = result.value(forKey: "konusu") as? String {
                            konuText.text = konu
                        }
                        if let sure = result.value(forKey: "sure") as? Int {
                            sureText.text = String(sure)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print ("error")
            }
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            konuText.text = ""
            sureText.text = ""
        }

        //Recognizer
        
        let gesturRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gesturRecognizer)

        imageView.isUserInteractionEnabled  = true
        let imageTapRecegnizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecegnizer)
    }
    
    //Fotağrafın tıklanıp galeriye gitmesini sağlayan kod
    
    @objc func selectImage () {
        
        var configuraation = PHPickerConfiguration()
        configuraation.filter = .images
        let picker = PHPickerViewController(configuration: configuraation)
        picker.delegate = self
        present ( picker , animated: true)

    }
     // seçtiğimiz görsel imageView'de gösterilmesini sağlar
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
        guard !results.isEmpty else {
                    return
                }
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self)  { [weak self] (image, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.imageView.image = image // UIImageView'e seçilen görüntüyü atama
                    }
                }
            }
        }
    }
    // Ekranın herhangi bir yerine tıkladığında klavye kapanmasını sağlar
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    // Veriyi Core Data'ya Saklama İşlemi
    
    @IBAction func kaydet(_ sender: Any) {
        
        let applDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = applDelegete.persistentContainer.viewContext
        let newFilm = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes / Öznitellikler
        
        newFilm.setValue(nameText.text!, forKey: "filmadi")
        newFilm.setValue(konuText.text!, forKey: "konusu")
        if let sure = Int(sureText.text!) {
            newFilm.setValue(sure , forKey: "sure")
        }
        newFilm.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newFilm.setValue(data, forKey: "image")
        
        do  {
            try context.save()
            print("sucsess")
        }
        catch {
            print("error")
        }
        
        //View Controller Arası Mesaj Göndermeye Sağlayan Kod
        
        NotificationCenter.default.post (name: NSNotification.Name("newData") , object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
