//
//  ViewControllerPerfil.swift
//  JSONRESTful
//
//  Created by Ruben Freddy Quea Jacho on 3/12/23.
//

import UIKit

class ViewControllerPerfil: UIViewController {
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    var user:Users?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            txtNombre.text = user!.nombre
            txtClave.text = user!.clave
            txtEmail.text = user!.email
        }
        
    }
    

    @IBAction func ActualizarPerfil(_ sender: Any) {
        let nombre = txtNombre.text!
        let clave = txtClave.text!
        let email = txtEmail.text!
        
        let datos = ["nombre": "\(nombre)", "clave": "\(clave)", "email": "\(email)"] as Dictionary<String, Any>
        
        let ruta = "http://localhost:3000/usuarios/\(user!.id)"
        metodoPUT(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
    
    func metodoPUT(ruta:String, datos: [String:Any]){
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let sesion = URLSession.shared
        
        request.httpMethod = "PUT"
        
        let params = datos
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch  {
            //
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = sesion.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if (data != nil) {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                } catch  {
                    //
                }
            }
        })
        task.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
