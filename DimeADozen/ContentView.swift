//
//  ContentView.swift
//  DimeADozen
//
//  Created by Adam J Mosher on 10/29/24.
//
//Notes as of 11/26: I HATE BUTTONS!!!!! - Adam :)


// TODO:
// Make a Monthly Subscription screen
// Make a Graph Screen


import SwiftUI
import Combine
import Charts

class BudgetManager: ObservableObject {
    @Published var budget: Int
    @Published var remainingBudget: Int
    @Published var purchases: [String: Double] = [:]

    init(budget: Int) {
        self.budget = budget
        self.remainingBudget = budget
    }

    func addPurchase(itemName: String, price: Double) {
        guard remainingBudget >= Int(price) else { return }
        purchases[itemName] = price
        remainingBudget -= Int(price)
    }
}

struct ContentView: View {
    @StateObject private var budgetManager = BudgetManager(budget: 1000) // Example starting budget

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Welcome to DimeADozen.")
                        .font(.title)
                        .bold()
                        .padding()

                    NavigationLink(destination: MainPage(budgetManager: budgetManager)) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
    }
}

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

                    Button(action: {
                        if let validBudget = Int(budgetInput) {
                            budget = validBudget
                            isNavigating = true
                        }
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: .infinity)
                            .background(budgetInput.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(budgetInput.isEmpty)
                    .padding(.horizontal)
                }
                .navigationDestination(isPresented: $isNavigating) {
                    if let validBudget = budget {
                        // Create a BudgetManager instance and pass it to MainPage
                        MainPage(budgetManager: BudgetManager(budget: validBudget))
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct MainPage: View {
    @ObservedObject var budgetManager: BudgetManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Budget:")
                            .font(.headline)

                        Text("$\(budgetManager.remainingBudget) / $\(budgetManager.budget)")
                            .font(.largeTitle)
                            .bold()

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 20)

                                RoundedRectangle(cornerRadius: 10)
                                    .fill(barColor)
                                    .frame(width: CGFloat(remainingPercentage) * geometry.size.width, height: 20)
                            }
                        }
                        .frame(height: 20)
                    }
                    .padding()

                    ZStack {
                        Color.black
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Purchases")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding([.top, .horizontal])

                            if budgetManager.purchases.isEmpty {
                                Text("No purchases yet.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(Array(recentPurchases), id: \.key) { purchase in
                                    HStack {
                                        Text(purchase.key)
                                            .foregroundColor(.white)
                                            .bold()

                                        Spacer()

                                        Text("$\(String(format: "%.2f", purchase.value))")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Navigation Links
                    HStack(spacing: 20) {
                        NavigationLink(destination: MainPage(budgetManager: budgetManager)) {
                            VStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                Text("Home")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        
                        NavigationLink(destination: RecentPurchase(budgetManager: budgetManager)) {
                            VStack {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)

                                Text("Purchases")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }

                        NavigationLink(destination: Text("Bar Graph")) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding()
            }
        }
    }

    private var recentPurchases: [Dictionary<String, Double>.Element] {
        Array(budgetManager.purchases.sorted { $0.key > $1.key }.prefix(5))
    }

    private var remainingPercentage: Double {
        max(0.0, Double(budgetManager.remainingBudget) / Double(budgetManager.budget))
    }

    private var barColor: Color {
        switch remainingPercentage {
        case 0.3...0.5: return .yellow
        case 0...0.3: return .red
        default: return .darkgreen
        }
    }
}

struct RecentPurchase: View {
    @ObservedObject var budgetManager: BudgetManager
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                ZStack {
                    Color.black
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Purchases")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding([.top, .horizontal])

                        if budgetManager.purchases.isEmpty {
                            Text("No purchases yet.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(Array(recentPurchases), id: \.key) { purchase in
                                HStack {
                                    Text(purchase.key)
                                        .foregroundColor(.white)
                                        .bold()

                                    Spacer()

                                    Text("$\(String(format: "%.2f", purchase.value))")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }

                // "Add Purchase" Button
                NavigationLink(destination: EnterPurchase(purchases: $budgetManager.purchases, remainingBudget: $budgetManager.remainingBudget)) {
                    Text("Add Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }

                Spacer()

                // Navigation Links (Home, Purchases, Bar Graph)
                HStack(spacing: 20) {
                    NavigationLink(destination: MainPage(budgetManager: budgetManager)) {
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            
                            Text("Home")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }

                    NavigationLink(destination: RecentPurchase(budgetManager: budgetManager)) {
                        VStack {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)

                            Text("Purchases")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }

                    NavigationLink(destination: Text("Bar Graph")) {
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding()
        }
    }

    private var recentPurchases: [Dictionary<String, Double>.Element] {
        Array(budgetManager.purchases.sorted { $0.key > $1.key }.prefix(5))
    }
}

struct EnterPurchase: View {
    @Binding var purchases: [String: Double] // Binding to update the purchases dictionary
    @Binding var remainingBudget: Int // Binding to update the remaining budget
    @State private var itemName: String = "" // Item name input
    @State private var itemPrice: String = "" // Item price input (as string for text field compatibility)
    @State private var errorMessage: String? = nil // Error message for invalid inputs
    @Environment(\.dismiss) private var dismiss // Environment action for dismissing the view

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                // Title
                Text("Enter New Purchase")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                // Input fields for item name and price
                VStack(spacing: 10) {
                    TextField("Item Name", text: $itemName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)

                    TextField("Item Price", text: $itemPrice)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }

                // Error message display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                // Submit button to add the purchase
                Button(action: {
                    addPurchase()
                }) {
                    Text("Add Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }

                // Back button to dismiss and go back to the previous view
                Button(action: {
                    dismiss() // Dismiss the current view
                }) {
                    Text("Back to Purchases")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }

    // Function to add purchase
    private func addPurchase() {
        guard !itemName.isEmpty else {
            errorMessage = "Item name cannot be empty."
            return
        }

        guard let price = Double(itemPrice), price > 0 else {
            errorMessage = "Enter a valid price greater than zero."
            return
        }

        guard price <= Double(remainingBudget) else {
            errorMessage = "Price exceeds remaining budget."
            return
        }

        // Add the purchase and subtract from the budget
        purchases[itemName] = price
        remainingBudget -= Int(price)
        errorMessage = nil
        itemName = ""
        itemPrice = ""
    }
}

// Preview
#Preview {
    ContentView()
}
