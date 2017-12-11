//
//  ViewController.swift
//  RectoriaBot
//
//  Created by eventos on 11/21/17.
//  Copyright © 2017 eventos. All rights reserved.
//

import UIKit
import TextToSpeechV1
import ConversationV1
import SpeechToTextV1
import AVFoundation
import Foundation

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
     /*
     ConversationUsername = "412cfe7b-db06-4bea-af43-40fc71ffc3b7"
     ConversationPassword = "gx7gV0nJUL4c"
     ConversationWorkspace = "79594e4d-2deb-4cb5-9c4d-f2ab0067250e"
     */
    
    @IBOutlet weak var microfono: UIButton!
    var audioPlayer: AVAudioPlayer!
    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var isStreaming = false
    var res: String = "Bienvenido"
    let semaphore = DispatchSemaphore(value: 1)
    
    @IBOutlet weak var texto: UITextView!
    @IBOutlet weak var output: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechToText = SpeechToText(
            username: "9cfb437d-1952-402b-b7b1-1c8a29bcb94f",
            password: "4hHT7k3kFxlx"
        )
        speechToTextSession = SpeechToTextSession(
            username: "9cfb437d-1952-402b-b7b1-1c8a29bcb94f",
            password: "4hHT7k3kFxlx"
        )
        TTS()
    }
    //Al hacer click en el boton de microfono, activar Speech to Text
    @IBAction func onClickMicButton(_ sender: Any) {
        //Llamar Speech To Text
        streamMicrophoneBasic()
        //Llamar funcion de Conversational
        //texto.text = res
        //Llamar funcion de Text to Speech
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Funcion que utiliza el Text to Speech de Watson, enviando como parametro el texto que se encuentre en el Text Field
    public func TTS (){
        semaphore.wait()
        res = res.replacingOccurrences(of: "[", with: "")
        res = res.replacingOccurrences(of: "]", with: "")
        res = res.replacingOccurrences(of: "\"", with: "")
        self.output.text = self.res
        let username = "74a05956-62ae-474e-98c8-5e9fb289a0df"
        let password = "qkiIuj6Jr5Dt"
        let textToSpeech = TextToSpeech(username: username, password: password)
        textToSpeech.synthesize(res, voice: "es-LA_SofiaVoice") { audio in
            self.audioPlayer = try! AVAudioPlayer(data: audio)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        }
        let failure = { (error: Error) in print(error) }
        textToSpeech.synthesize(res, voice: "es-LA_SofiaVoice", failure: failure){data in
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.play()
        }
    }
    
    public func streamMicrophoneBasic() {
        if !isStreaming {
            microfono.setImage(UIImage(named: "24992449_10214717920922527_1355465750_n.png"), for: .normal)
            // update state
            //microphoneButton.setTitle("Stop Microphone", for: .normal)
            isStreaming = true
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.interimResults = true
            
            // define error function
            let failure = { (error: Error) in print(error) }
            
            // start recognizing microphone audio
            speechToText.recognizeMicrophone(settings: settings, model: "es-ES_BroadbandModel", learningOptOut: false, compress: false, failure: failure){
                results  in
                self.texto.text = results.bestTranscript
            }/*
            speechToText.recognizeMicrophone(settings: settings, failure: failure) {
                results in
                self.texto.text = results.bestTranscript
            }*/
            
        } else {
            microfono.setImage(UIImage(named: "mediabug-electronics-microphone-icon.png"), for: .normal)
            // update state
            //microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToText.stopRecognizeMicrophone()
        }
    }
    
    @IBAction func enviar(_ sender: Any) {
        Convo()
        TTS()
    }
    
    
    
    
    public func Convo(){
        let username = "412cfe7b-db06-4bea-af43-40fc71ffc3b7"
        let password = "gx7gV0nJUL4c"
        let version = "2017-12-04" // use today's date for the most recent version
        let conversation = Conversation(username: username, password: password, version: version)
        let workspaceID = "79594e4d-2deb-4cb5-9c4d-f2ab0067250e"
        let input = InputData(text:texto.text)
        let failure = { (error: Error) in print(error) }
        var context: Context? // save context to continue conversation
        let request = MessageRequest(input:input, context:context)
        conversation.message(workspaceID: workspaceID, request: request,failure: failure) {
            response in
            print("response")
            print(response.output.text)
            context = response.context
            self.res = response.output.text.description
            print("res")
            print(self.res)
            self.semaphore.signal()
        }
    }
    
    
    ////////imágenes
    @IBOutlet weak var imageTake: UIImageView!
    
    @IBAction func photoClick(_ sender: Any) {
        /*if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var imagePicker2 = UIImagePickerController()
            imagePicker2.delegate = self
            imagePicker2.sourceType = .photoLibrary;
            imagePicker2.allowsEditing = true
            self.present(imagePicker2, animated: true, completion: nil)
        }*/
        UploadRequest()
    }
    
    
    ///////////////
    func UploadRequest()
    {
        let url = URL(string: "http://10.14.189.58/run_classifier.php")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (imageTake.image == nil)
        {
            return
        }
        
        let image_data = UIImagePNGRepresentation(imageTake.image!)
        
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        
        request.httpBody = body as Data
        
        
        
        let session = URLSession.shared
        print("aaaaaaaaaa")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard ((data) != nil), let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:[String:String]]
                var obj = json!["1"]!["name"] as! String
                print(obj)
                
                
            }
            catch{
                
            }
            
            /*
            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                print(dataString)
                
                self.output.text = dataString as String!
            }*/
            
        })
        
        task.resume()
        print("bbbbbbb")
        
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
}


