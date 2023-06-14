//
//  ViewController.swift
//  SozlukApp
//
//  Created by Salih Yusuf Göktaş on 20.05.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var kelimeTableView: UITableView!
	
	var kelimeListesi = [Kelimeler]()
	
	var ref:DatabaseReference!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tumKelimelerAl()
		
		kelimeTableView.delegate = self
		kelimeTableView.dataSource = self
		
		searchBar.delegate = self
		
		ref = Database.database().reference()
		
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let indeks = sender as? Int
		
		let gidilecekVC = segue.destination as! KelimeDetayViewController
		
		gidilecekVC.kelime = kelimeListesi[indeks!]
	}
	
	func tumKelimelerAl(){
		ref?.child("kelimeler").observe(.value, with: { snapshot in
			if let gelenVeriButunu = snapshot.value as? [String:AnyObject] {
				self.kelimeListesi.removeAll()
				
				for gelenSatirVerisi in gelenVeriButunu {
					
					if let sozluk = gelenSatirVerisi.value as? NSDictionary{
						let key = gelenSatirVerisi.key
						let turkce = sozluk["turkce"] as? String ?? ""
						let ingilizce = sozluk["ingilizce"] as? String ?? ""
						
						let kelime = Kelimeler(kelime_id: key, ingilizce: ingilizce, turkce: turkce)
						
						self.kelimeListesi.append(kelime)
						
					}
				}
				DispatchQueue.main.async {
					self.kelimeTableView.reloadData()
				}
				
			}
		})
	}
	func aramaYap(aramaKelimesi:String){
		
		ref.child("kelimeler").observe(.value, with: { snapshot in
			if let gelenVeriButunu = snapshot.value as? [String:AnyObject] {
				self.kelimeListesi.removeAll()
				
				for gelenSatirVerisi in gelenVeriButunu {
					
					if let sozluk = gelenSatirVerisi.value as? NSDictionary{
						let key = gelenSatirVerisi.key
						let turkce = sozluk["turkce"] as? String ?? ""
						let ingilizce = sozluk["ingilizce"] as? String ?? ""
						
						if ingilizce.contains(aramaKelimesi){
							let kelime = Kelimeler(kelime_id: key, ingilizce: ingilizce, turkce: turkce)
							
							self.kelimeListesi.append(kelime)
						}
					}
				}
				DispatchQueue.main.async {
					self.kelimeTableView.reloadData()
				}
				
			}
		})
	}
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
	
	// Kaç bölüm olacak
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// Bir bölüm içerisinde kaç satır olacak
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return kelimeListesi.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let kelime = kelimeListesi[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "kelimeHucre", for: indexPath) as! KelimeHucreTableViewCell
		
		cell.ingilizceLabel.text = kelime.ingilizce
		cell.turkceLabel.text = kelime.turkce
		
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "toKelimeDetay", sender: indexPath.row)
	}
}

extension ViewController:UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print("Arama Sonucu : \(searchText)")
  
  
  if searchText == "" {
	  tumKelimelerAl()
  }else{
	  aramaYap(aramaKelimesi:searchText)
  }
  
  
}
	
}
