//
//  ViewControllerBuscar.swift
//  JSONRESTful
//
//  Created by Ruben Freddy Quea Jacho on 28/11/23.
//

import UIKit

class ViewControllerBuscar: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    var peliculas = [Peliculas]()
    var user:Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
        
        if user != nil {
            let ruta1 = "http://localhost:3000/usuarios/\(user!.id)"
            print(ruta1)
            obtenerUsuario(ruta: ruta1){
                response in
                self.user = response
                
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero: \(peliculas[indexPath.row].genero) Duracion: \(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mostrarAlertaEliminar(indexPath: indexPath)
        }
    }
    
    func mostrarAlertaEliminar(indexPath: IndexPath) {
        let alertaEliminar = UIAlertController(title: "Eliminar Película", message: "¿Seguro que desea eliminar esta película?", preferredStyle: .alert)

        let actionSi = UIAlertAction(title: "Sí", style: .destructive) { (_) in
            self.eliminarPeliculaEnIndexPath(indexPath)
        }

        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)

        alertaEliminar.addAction(actionSi)
        alertaEliminar.addAction(actionNo)

        present(alertaEliminar, animated: true, completion: nil)
    }
    
    func eliminarPeliculaEnIndexPath(_ indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        let ruta = "http://localhost:3000/peliculas/\(pelicula.id)"
        metodoDELETE(ruta: ruta)
        peliculas.remove(at: indexPath.row)
        tablaPeliculas.deleteRows(at: [indexPath], with: .fade)
    }
    
    func metodoDELETE(ruta: String) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let sesion = URLSession.shared

        request.httpMethod = "DELETE"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = sesion.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error al eliminar la película: \(error)")
            } else if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(dict)
                } catch {
                    print("Error al procesar la respuesta JSON después de eliminar la película.")
                }
            }
        })

        task.resume()
    }

    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editarPerfil(_ sender: Any) {
        performSegue(withIdentifier: "segueEditarPerfil", sender: self.user)
    }
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/peliculas/?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        
        if nombre.isEmpty{
            let ruta = "http://localhost:3000/peliculas/"
            self.cargarPeliculas(ruta: ruta){
                self.tablaPeliculas.reloadData()
            }
        }else {
            cargarPeliculas(ruta: crearURL) {
                if self.peliculas.count <= 0{
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias Para : \(nombre)", accion: "cancel")
                }else{
                    self.tablaPeliculas.reloadData()
                }
            }
        }
        
    }
    
    func cargarPeliculas(ruta:String, completed: @escaping () -> ()){
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            if error == nil{
                do {
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error en JSON")
                }
            }
        }.resume()
    }
    
    func obtenerUsuario(ruta: String, completed: @escaping (Users) -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.user = try JSONDecoder().decode(Users.self, from: data!)
                    DispatchQueue.main.async {
                        completed(self.user!)
                    }
                } catch {
                    print("Error en JSON")
                }
            }
        }.resume()
    }


    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: UIAlertAction.Style.default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar"{
            let siguienteVC = segue.destination as! ViewControllerAgregar
            siguienteVC.pelicula = sender as? Peliculas
        }
        else if segue.identifier == "segueEditarPerfil"{
            if user != nil {
                //
                let siguienteVC = segue.destination as! ViewControllerPerfil
                siguienteVC.user = sender as? Users
                print("USUARIO RECIBIDO, \(user)")
            }
        }
    }
}
