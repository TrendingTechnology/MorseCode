//
//  MorseFlash.swift
//  Morse Code
//
//  Created by Asad Azam on 21/08/20.
//  Copyright © 2020 Asad. All rights reserved.
//

import SwiftUI
import AVFoundation

struct MorseFlash: View {
    @State var convertFrom: String = ""
    @State var convertedTo: String = "Converted Text"
    @State var currentTitle: String = "Convert"
    @State var wpmPicker: Int = 20
    var duration: Float = 0.06
    
    //MARK: Adiitional States for SwiftUI
    @State var isUserInteractionEnabled: Bool = true
    @State var repeatFlash: Bool = false
    @State var forceFlashStop: Bool = false

    //MARK: END
    
    var body: some View {
        ZStack{
            Color(UIColor.tertiarySystemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        Text("\(convertedTo)")
                            .padding(.all, 5)
                            .lineLimit(nil)
                        Spacer(minLength: 0)
                    }
                    
                    Spacer()
                }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)), radius: 5)
                .padding(.horizontal, 20)
                Spacer()
                HStack{
                    //This spacer makes sure the
                    Spacer(minLength: UIScreen.main.bounds.width/2 - 60)
                    Button(action: {
                        self.convertToMorse()
                    }) {
                        Text("\(currentTitle)")
                    }
                    .frame(width: 120, height: 60)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    Spacer()
                    
                    if self.repeatFlash == false {
                        Button(action: {
                            self.repeatFlash.toggle()
                        }) {
                            Image(systemName: "repeat")
                        }
                        .frame(width: 39, height: 34)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .foregroundColor(Color(UIColor.systemGray6))
                    } else {
                        Button(action: {
                            self.repeatFlash.toggle()
                        }) {
                            Image(systemName: "repeat")
                        }
                        .frame(width: 39, height: 34)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .foregroundColor(Color(UIColor.systemBlue))
                    }
                    Spacer()
                }
                Spacer()
                VStack {
                    VStack {
                        HStack {
                            TextField("Text to Convert", text: $convertFrom)
                                .padding(.all, 5)
                                .lineLimit(nil)
                            Spacer(minLength: 0)
                        }
                        Spacer()
                        
                    }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)), radius: 5)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitle("Flash")
    }
    
//MARK: Convert Button (Flash)
    func convertToMorse() {
        if currentTitle == "Convert" {
            if (convertFrom != "") {
//                convertFrom.resignFirstResponder()
                morseCodeText = convertFrom
                initializeString(toConvert: &morseCodeText)
                tempConvert()
                if repeatFlash == false {
                    convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode )
                } else {
                    convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
                }
            } else {
                showAlertWith(title: "No Input!", message: "Input field cannot be empty")
            }
        } else {
            if repeatFlash == true {
                repeatFlash = false
            }
            forceFlashStop = true
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = AVCaptureDevice.TorchMode.off
            } catch {
                print("There was an error : \(error.localizedDescription)")
            }
            currentTitle = "Convert"
        }
    }
    
//MARK: Support Function(s)
    //Modifies Morse to display in correct format to display
    func tempConvert() {
        convertedTo = ""
        for index in 0..<morseCodeText.length {
            let tempString = mapMorseCode[morseCodeText[index]] ?? "#"
            convertedTo = convertedTo + " " + tempString
        }
    }
    
    //Hides keyboard when enter/done is pressed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
//            convertFrom.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Alerter
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
    }
    
    //Toggles the flash on or off
    func toggleFlash() {
        if forceFlashStop == false {
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else { return }

            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print("There was an error : \(error.localizedDescription)")
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print("There was an error : \(error.localizedDescription)")
            }
        }
    }

//MARK: Main Convert Function and Logic
    //Converts Text to Morse Code and starts the flashlight
    func convert(morseCodeText: String, mapMorseCode: [String:String]){
        currentTitle = "Stop"
        DispatchQueue.global(qos: .utility).async {
            for index in 0..<morseCodeText.length {
                let tempString = mapMorseCode[morseCodeText[index]] ?? "#"
                if (tempString == "/") {
                    do { usleep(360000) }
                }
                for j in 0..<tempString.length {
                    if (tempString[j] == ".") {
                        self.toggleFlash()
                        do { usleep(60000) }
                        self.toggleFlash()
                    }
                    else if (tempString[j] == "-") {
                        self.toggleFlash()
                        do { usleep(180000) }
                        self.toggleFlash()
                        do {usleep(60000)}
                    }
                    do { usleep(60000) }
                }
                do { usleep(120000) }
            }
            DispatchQueue.main.async {
                self.forceFlashStop = false
                if self.repeatFlash == true {
                    do { usleep(480000) }
                    self.convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
                } else {
                    self.currentTitle = "Convert"
                }
                guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
                do {
                    try device.lockForConfiguration()
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } catch {
                    print("There was an error : \(error.localizedDescription)")
                }
            }
        }
    }

//MARK: objC Function(s)
//    @objc func handleKeyboardNotification(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//            if notification.name == UIResponder.keyboardWillShowNotification {
//                convertFrom.frame.origin.y -= keyboardFrame.height
//                convertFrom.frame.origin.y += 10
//            }
//            else if notification.name == UIResponder.keyboardWillHideNotification {
//                convertFrom.frame.origin.y += keyboardFrame.height
//                convertFrom.frame.origin.y -= 10
//            }
//        }
//    }
    
//MARK: Deinitializer
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
    
//MARK: MorseFlash Struct END
}

struct MorseFlash_Previews: PreviewProvider {
    static var previews: some View {
        MorseFlash()
    }
}