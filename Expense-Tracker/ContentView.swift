import SwiftUI
import Foundation

// MARK: - Models
struct Transaction: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var category: TransactionCategory
    var date: Date
    var isIncome: Bool
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "hu_HU")
        return formatter.string(from: NSNumber(value: amount)) ?? "0 Ft"
    }
}

enum TransactionCategory: String, CaseIterable, Codable {
    case food = "Étel"
    case transport = "Közlekedés"
    case entertainment = "Szórakozás"
    case shopping = "Vásárlás"
    case salary = "Fizetés"
    case other = "Egyéb"
    
    var emoji: String {
        switch self {
        case .food: return "🍕"
        case .transport: return "🚗"
        case .entertainment: return "🎬"
        case .shopping: return "🛍️"
        case .salary: return "💰"
        case .other: return "📝"
        }
    }
}

// MARK: - ViewModels
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "SavedTransactions"
    
    init() {
        loadTransactions()
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(at indices: IndexSet) {
        transactions.remove(atOffsets: indices)
        saveTransactions()
    }
    
    var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            transaction.isIncome ? total + transaction.amount : total - transaction.amount
        }
    }
    
    var monthlyIncome: Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return transactions.filter { transaction in
            let transactionMonth = Calendar.current.component(.month, from: transaction.date)
            let transactionYear = Calendar.current.component(.year, from: transaction.date)
            return transaction.isIncome && transactionMonth == currentMonth && transactionYear == currentYear
        }.reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpenses: Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return transactions.filter { transaction in
            let transactionMonth = Calendar.current.component(.month, from: transaction.date)
            let transactionYear = Calendar.current.component(.year, from: transaction.date)
            return !transaction.isIncome && transactionMonth == currentMonth && transactionYear == currentYear
        }.reduce(0) { $0 + $1.amount }
    }
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            userDefaults.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func loadTransactions() {
        if let data = userDefaults.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var showingAddTransaction = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Egyenleg kártya
                BalanceCard(balance: viewModel.totalBalance,
                           income: viewModel.monthlyIncome,
                           expenses: viewModel.monthlyExpenses)
                
                // Tranzakciók lista
                TransactionsList(transactions: viewModel.transactions) { indices in
                    viewModel.deleteTransaction(at: indices)
                }
                
                Spacer()
            }
            .navigationTitle("Pénzügyek")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView { transaction in
                    viewModel.addTransaction(transaction)
                }
            }
        }
    }
}

struct BalanceCard: View {
    let balance: Double
    let income: Double
    let expenses: Double
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Jelenlegi egyenleg")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(balance))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(balance >= 0 ? .green : .red)
            }
            
            HStack {
                VStack {
                    Text("Havi bevétel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(income))
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack {
                    Text("Havi kiadás")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(expenses))
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "hu_HU")
        return formatter.string(from: NSNumber(value: amount)) ?? "0 Ft"
    }
}

struct TransactionsList: View {
    let transactions: [Transaction]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(transactions.sorted(by: { $0.date > $1.date })) { transaction in
                TransactionRow(transaction: transaction)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Text(transaction.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(transaction.isIncome ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                .font(.headline)
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "hu_HU")
        return formatter.string(from: date)
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = TransactionCategory.food
    @State private var isIncome = false
    @State private var selectedDate = Date()
    
    let onSave: (Transaction) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tranzakció részletei")) {
                    TextField("Megnevezés", text: $title)
                    
                    TextField("Összeg", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Kategória", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Dátum", selection: $selectedDate, displayedComponents: .date)
                    
                    Toggle("Bevétel", isOn: $isIncome)
                }
            }
            .navigationTitle("Új tranzakció")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Mégsem") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mentés") {
                        saveTransaction()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        let transaction = Transaction(
            title: title,
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate,
            isIncome: isIncome
        )
        
        onSave(transaction)
        dismiss()
    }
}

// MARK: - App Entry Point
// Az App entry point külön fájlban van (Expense_TrackerApp.swift)

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
