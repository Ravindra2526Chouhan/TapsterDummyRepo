/// Describes a type of credit card for a subset of known types.
enum CreditCardType: CustomStringConvertible {
	case amex, dinersClub, discover, jcb, masterCard, visa, unknown
	
	var description: String {
		switch self {
		case .amex:
			return "Amex"
		case .dinersClub:
			return "DinersClub"
		case .discover:
			return "Discover"
		case .jcb:
			return "JCB"
		case .masterCard:
			return "Mastercard"
		case .visa:
			return "Visa"
		case .unknown:
			return "Unknown"
		}
	}
	
	
	/// A set of lengths that are considered valid for the type
	var validLengths: Set<Int> {
		switch self {
		case .amex:
			return [15]
		case .dinersClub:
			return [14, 15, 16]
		case .discover:
			return [16]
		case .jcb:
			return [16]
		case .masterCard:
			return [16]
		case .visa:
			return [13, 16]
		case .unknown:
			return []
		}
	}
	
	init(number: String) {
		
		if let first = number.prefixAsInt(1), first == 4 {
			self = .visa
			return
		}
		
		if let firstTwo = number.prefixAsInt(2) {
			if firstTwo == 35 {
				self = .jcb
				return
			}
			
			if [30, 36, 38, 39].contains(firstTwo) {
				self = .dinersClub
				return
			}
			
			if 50...55 ~= firstTwo {
				self = .masterCard
				return
			}
			
			if firstTwo == 34 || firstTwo == 37 {
				self = .amex
				return
			}
			
			if firstTwo == 65 {
				self = .discover
				return
			}
		}
		
		if let firstThree = number.prefixAsInt(3), 644...649 ~= firstThree {
			self = .discover
			return
		}
		
		if let firstFour = number.prefixAsInt(4), firstFour == 6011 {
			self = .discover
			return
		}
		
		if let firstSix = number.prefixAsInt(6), 622126...622925 ~= firstSix {
			self = .discover
			return
		}
		
		self = .unknown
	}
}

private extension String {
	
	/**
	The first `length` characters of the String as an Int.
	
	:param: length The number of characters to return
	
	:returns: The first `length` characters of the String as an Int. `nil` if `length` exceed the length of the String or is not representable as Int.
	*/
	func prefixAsInt(_ length: Int) -> Int? {
		if self.characters.count < length {
			return nil
		}
		
		return Int(substring(with: startIndex..<characters.index(startIndex, offsetBy: length)))
	}
	
}

/// Represents a String as a Credit Card
struct CreditCard {
	
	/// The credit card number represented as a String
	let number: String
	
	/// The type of credit card, this is generally accurate once the first two numbers are provided
	var type: CreditCardType { return CreditCardType(number: number) }
	
	/// The last 4 numbers of the card, nil if the length is < 4
	var last4: String? {
		if number.characters.count < 4 {
			return nil
		}
		
		let startIndex = number.characters.index(number.endIndex, offsetBy: -4)
		return number.substring(from: startIndex)
		//    return number.substringWithRange(advance(number.endIndex, -4)..<number.endIndex)
	}
	
	/// A display version of the credit card number
	var formattedString: String {
		return number
	}
	
	/// True when both `isValidLength` and `isValidLuhn` are true
	var isValid: Bool {
		return isValidLength && isValidLuhn
	}
	
	/// True when the length of the card number meets a required length for the card type
	var isValidLength: Bool {
		return type.validLengths.contains(number.characters.count)
		//    return contains(type.validLengths, count(number))
	}
	
	/// True when the Luhn algorithm https://en.wikipedia.org/wiki/Luhn_algorithm succeeds
	var isValidLuhn: Bool {
		var sum = 0
		let digitStrings = number.characters.reversed().map { String($0) }
		
		for tuple in digitStrings.enumerated() {
			if let digit = Int(tuple.element) {
//				let odd = tuple.index % 2 == 1
                let odd = tuple.offset % 2 == 1 //02-01-2017
				
				switch (odd, digit) {
				case (true, 9):
					sum += 9
				case (true, 0...8):
					sum += (digit * 2) % 9
				default:
					sum += digit
				}
			} else {
				return false
			}
		}
		return sum % 10 == 0
	}
	
	init(string: String) {
		self.number = string
	}
	
}
