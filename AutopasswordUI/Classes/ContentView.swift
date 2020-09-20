//
//  ContentView.swift
//  AutopasswordUI
//
//  Created by Paolo on 20/09/2020.
//

import SwiftUI
import MobileCoreServices

struct ContentView: View {
	@State private var pinFactor	= ""
	@State private var urlString	= ""
	@State private var userEmail	= ""
	
	var resultPassword: String {
		guard pinFactor.count > 3 else { return "PIN must be >= 4 chars" }
		guard urlString.count > 9, let urlFactor = URL(string: urlString) else {
			return "URL must be valid >= 10 chars"
		}
		guard userEmail.count > 4 else { return("User name must be >= 5 chars") }
		
		let completeSeed	= pinFactor + (urlFactor.host ?? "") + userEmail
		
		if let hashValue = Base64.SHA256(completeSeed), hashValue.count >= 16 {
			let index1  = hashValue.index(hashValue.startIndex, offsetBy: 4)
			let index2  = hashValue.index(index1, offsetBy: 4)
			let index3  = hashValue.index(index2, offsetBy: 4)
			let index4  = hashValue.index(index3, offsetBy: 4)
			
			let chunk1  = hashValue[..<index1]
			let chunk2  = hashValue[index1..<index2]
			let chunk3  = hashValue[index2..<index3]
			let chunk4  = hashValue[index3..<index4]
			
			let resultValue	= "\(chunk1)-\(chunk2)-\(chunk3)-\(chunk4)"
			
			UIPasteboard.general.setValue(resultValue, forPasteboardType: kUTTypeUTF8PlainText as String)
			
			return resultValue
		} else {
			return "Parameters are invalid for a proper hash"
		}
	}
	
	var body: some View {
        Form {
            Section {
                Text("Password Generator").bold()
            }
            Section(header: Text("Password parameters").bold()) {
                SecureField("PIN Code", text: $pinFactor).keyboardType(.numberPad)
                TextField("Site URL", text: $urlString)
                    .keyboardType(.URL).autocapitalization(.none).disableAutocorrection(true)
                TextField("Username / Email", text: $userEmail)
                    .keyboardType(.emailAddress).autocapitalization(.none).disableAutocorrection(true)
            }
            Section(header: Text("Resulting password").bold()) {
                Text(resultPassword)
            }
        }
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
