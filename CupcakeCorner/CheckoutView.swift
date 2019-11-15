//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by PBB on 2019/11/13.
//  Copyright © 2019 PBB. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: OrderClass
//    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                    
                    Text("Your total is $\(self.order.order.cost, specifier: "%.2f")")
                        .font(.title)
                    
                    Button("Place Order") {
                        self.placeOrder()
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Check out", displayMode: .inline)
        .alert(isPresented: $showingConfirmation) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
        }
//        .alert(isPresented: $showErrorAlert) {
//            Alert(title: Text("Oops, Something's Wrong"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
    }
    
    func placeOrder() {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            alertTitle = "Oops, Something's Wrong"
            alertMessage = "Failed to encode order"
            self.showingConfirmation = true
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                self.alertTitle = "Oops, Something's Wrong"
                self.alertMessage = "No data in response: \(error?.localizedDescription ?? "Unknown error")."
                self.showingConfirmation = true
                return
            }
            
            if let decodedOrder = try? JSONDecoder().decode(OrderClass.self, from: data) {
                let confirmationMessage = "Your order for \(decodedOrder.order.quantity)x \(Order.types[decodedOrder.order.type].lowercased()) cupcakes is on its way!"
                self.alertTitle = "Thank you!"
                self.alertMessage = confirmationMessage
                self.showingConfirmation = true
            } else {
                print("Invalid response from server")
                self.alertTitle = "Oops, Something's Wrong"
                self.alertMessage = "Invalid response from server"
                self.showingConfirmation = true
            }
        }.resume()
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: OrderClass())
    }
}
