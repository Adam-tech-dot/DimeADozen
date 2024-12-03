//
//  ContentView.swift
//  DimeADozen
//
//  Created by Adam J Mosher on 10/29/24.
//


import SwiftUI
import Charts

// Class dedicated to manage the budget and update the current budget
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

// Startup screen to welcome the user to DimeADozen
struct ContentView: View {
    @StateObject private var budgetManager = BudgetManager(budget: 0)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Welcome to DimeADozen.")
                        .font(.title)
                        .bold()
                        .padding()

                    NavigationLink(destination: SetUp(budgetManager: budgetManager)) {
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

// Allows the user to add a budget and stores that value in the BudgetManager class
struct SetUp: View {
    @ObservedObject var budgetManager: BudgetManager
    @State private var budgetInput: String = ""
    @State private var navigateToMainPage: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Set Up Your Budget")
                        .font(.title)
                        .bold()
                        .padding()

                    TextField("Enter your budget", text: $budgetInput)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .padding()

                    Button(action: {
                        if let validBudget = Int(budgetInput) {
                            budgetManager.budget = validBudget
                            budgetManager.remainingBudget = validBudget
                            navigateToMainPage = true // Trigger navigation
                        }
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(budgetInput.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(budgetInput.isEmpty)
                }
                .navigationDestination(isPresented: $navigateToMainPage) {
                    MainPage(budgetManager: budgetManager)
                }
            }
        }
    }
}

// The main page. Get to see purchases as well as seeing the where you are in the budget
struct MainPage: View {
    @ObservedObject var budgetManager: BudgetManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Budget:")
                            .font(.headline)

                        Text("$\(budgetManager.remainingBudget) / $\(budgetManager.budget)")
                            .font(.largeTitle)
                            .bold()

                        // Bar dedicated to visually show where the user is on their budget
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

                        // Shows recent purchases
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

                        NavigationLink(destination: GraphView(budgetManager: budgetManager)) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                Text("Graph")
                                    .foregroundColor(.white)
                                    .font(.caption)
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
            .navigationTitle("Home")
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
        NavigationStack {
            ZStack {
                Color.green
                    .ignoresSafeArea(.all)

                VStack(spacing: 20) {
                    ZStack {
                        Color.black
                    
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Purchases")
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

                        NavigationLink(destination: GraphView(budgetManager: budgetManager)) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                Text("Graph")
                                    .foregroundColor(.white)
                                    .font(.caption)
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
            .navigationTitle("Purchases") // Set the title to "Purchases"
        }
    }

    private var recentPurchases: [Dictionary<String, Double>.Element] {
        Array(budgetManager.purchases.sorted { $0.key > $1.key })
    }
}


struct EnterPurchase: View {
    @Binding var purchases: [String: Double]
    @Binding var remainingBudget: Int
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                Text("Enter New Purchase")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)

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

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

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

                Button(action: {
                    dismiss()
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
    
    // Add the purchase and subtract from the budget
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

        purchases[itemName] = price
        remainingBudget -= Int(price)
        errorMessage = nil
        itemName = ""
        itemPrice = ""
    }
}

struct GraphView: View {
    @ObservedObject var budgetManager: BudgetManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .edgesIgnoringSafeArea(.all)
            
                VStack {
                    Text("Purchases Breakdown")
                        .font(.headline)
                        .padding()

                    if budgetManager.purchases.isEmpty {
                        Text("No purchases to display.")
                            .foregroundColor(.gray)
                    } else {
                        Chart {
                            ForEach(budgetManager.purchases.sorted(by: { $0.value > $1.value }), id: \.key) { item, price in
                                BarMark(
                                    x: .value("Item", item),
                                    y: .value("Price", price)
                                )
                                .foregroundStyle(Color.black)
                            }
                        }
                        .frame(height: 300)
                        .padding()
                    }

                    Spacer()

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

                        NavigationLink(destination: GraphView(budgetManager: budgetManager)) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                Text("Graph")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom)  // Adjust padding if necessary
                }
                .padding()
            }
            .navigationTitle("Graph")
        }
    }
}


#Preview {
    ContentView()
}
