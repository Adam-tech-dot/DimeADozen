//
//  ContentView.swift
//  DimeADozen
//
//  Created by Adam J Mosher on 10/29/24.
//
//Notes as of 11/26: I HATE BUTTONS!!!!! - Adam :)


// TODO:
// Make a button to bring the user to the MainPage()
// Make the same button bring over budget
// Stylize the MainPage() (obviously why tf am I adding this?)

import SwiftUI

// Made by Adam Mosher
// Edited by
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .edgesIgnoringSafeArea(.all)
                
                Text("Welcome to DimeADozen.")
                    .font(.title)
                    .bold()
                
                VStack {
                    Spacer()
                    
                    NavigationLink(destination: SetUp()) {
                        Text("Get Started")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Made by Adam Mosher
// Edited by
struct SetUp: View {
    @State private var budgetInput: String = ""
    @State private var budget: Int? = nil
    @State private var isNavigating: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Let us set up a budget.")
                        .padding()
                        .font(.title)
                        .bold()

                    Text("You can always change this later.")
                        .padding()

                    TextField("Enter your budget", text: $budgetInput)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 300)
                        .padding()

                }
            }
        }
    }
}

// Made by Adam Mosher
// Edited by
struct MainPage: View {
    var body: some View {
        Text("Test")
    }
}

#Preview {
    ContentView()
}
