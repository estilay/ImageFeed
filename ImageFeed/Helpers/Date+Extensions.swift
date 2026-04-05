import Foundation

extension Date {
    var formattedDate: String { DateFormatter.dateFormatter.string(from: self) }
}
private extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}


