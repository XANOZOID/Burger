namespace burger;
using System;

enum TokenType {
	TokenLeftParen, TokenRightParen,
	TokenLeftBrace, TokenRightBrace,
	TokenLeftBracket, TokenRightBracket,
	TokenComma, TokenMinus, TokenPlus,
	TokenSemiColon, TokenSlash, TokenStar,

	TokenColon,
	// 1-2 Character Tokens....
	TokenBang, TokenBangEqual,
	TokenEqual, TokenEqualEqual,
	TokenGreater, TokenGreaterEqual,
	TokenLess, TokenLessEqual,
	TokenDot, TokenObjectEnter,

	TokenCoalesce, TokenQuestion, TokenNullAccessor,
	
	TokenOr,TokenAnd,

	// Literals
	TokenIdentifier, TokenString, TokenNumber,

	TokenSpreadRest,
	// Keywords
	TokenElse, TokenFalse, 
	TokenFor, TokenIf, TokenNull,
	TokenReturn, TokenThis,
	TokenTrue, TokenVar, TokenWhile,

	TokenTimes, TokenConst, TokenUnique, TokenLabel,
	TokenStatic, TokenSwitch, TokenBreak, TokenFallthrough,
	TokenCase, TokenContinue, TokenIn, TokenDo, TokenUntil,
	TokenSub, TokenScript,

	TokenError, TokenEOF
}

struct Token {
	public TokenType Type;
	public StringView Source;
	public int Line;
}

class Scanner {

	char8* sourceStart;
	StringView str;
	int64 line = 1;

	public this(char8* source)  {
		str = StringView(source, 0);
		sourceStart = source;
	}

	public void Reset() {
		str = StringView(sourceStart, 0);
	}

	bool IsAlpha(char8 c) {
		return (c >= 'a' && c <= 'z') ||
			   (c >= 'A' && c <= 'Z') ||
			   (c == '_');
	}

	bool IsDigit(char8 c) {
	  return (c >= '0' && c <= '9');
	}

	bool IsAtEnd() {
		return (str[[Unchecked] str.Length] == '\0');
	}

	char8 Advance() {
		str.Length ++;
		return str[str.Length - 1];
	}

	char8 Peek() {
		return str[[Unchecked] str.Length];
	}

	char8 PeekNext() {
		if (IsAtEnd()) return '\0';
		return str[[Unchecked] str.Length + 1];
	}

	bool Match(char8 expected) {
		if (IsAtEnd()) return false;
		if (Peek() != expected) return false;
		str.Length ++;
		return true;
	}

	Token MakeToken(TokenType type) {
		Token t = Token {
			Type = type,
			Source = str,
			Line = line
		};
		return t;
	}

	Token ErrorToken(StringView err) {
		Token t = Token {
			Type = .TokenError,
			Source = err,
			Line = line
		};
		return t;
	}

	void SkipWhitespace() {
		for (;;) {
			char8 c = Peek();

			switch(c) {
			case ' ', '\r', '\t':
				Advance();
			case '\n':
				line ++;
				Advance();
			case '/':
				if (PeekNext() == '/') {
					while (Peek() != '\n' && !IsAtEnd()) Advance();
				} else {
					return;
				}
			default:
				return;
			}
		}
	}

	TokenType IdentifierType() {
		switch (str) {
		/*case "&&": return .TokenAnd;*/
		/*case "||": return .TokenOr;*/
		case "else": return .TokenElse;
		case "false": return .TokenFalse;
		case "for": return .TokenFor;
		case "if": return .TokenIf;
		case "return": return .TokenReturn;
		case "this": return .TokenThis;
		case "true": return .TokenTrue;
		case "var": return .TokenVar;
		case "while": return .TokenWhile;
		case "do": return .TokenDo;
		case "until": return .TokenUntil;
		case "label": return .TokenLabel;
		case "const": return .TokenConst;
		case "sub": return .TokenSub;
		case "switch": return .TokenSwitch;
		case "case": return .TokenCase;
		case "break": return .TokenBreak;
		case "continue": return .TokenContinue;
		case "fallthrough": return .TokenFallthrough;
		case "in": return .TokenIn;
		case "times": return .TokenTimes;
		case "script": return .TokenScript;
		case "null": return .TokenNull;
		case "static": return .TokenStatic;
		}

		return .TokenIdentifier;
	}



	Token Identifier() {
		while (IsAlpha(Peek()) || IsDigit(Peek())) Advance();
		return MakeToken(IdentifierType());
	}

	Token Number() {
		while (IsDigit(Peek())) Advance();

		// look for fractional
		if (Peek() == '.' && IsDigit(PeekNext())) {
			// consume the decimal point
			Advance();
			while (IsDigit(Peek())) Advance();
		}

		return MakeToken(.TokenNumber);
	}

	Token String() {
		while (Peek() != '"' && !IsAtEnd()) {
			if (Peek() == '\n') line ++;
			Advance();
		}

		if (IsAtEnd()) return ErrorToken("Unterminated string.");

		// closing quote
		Advance();
		return MakeToken(.TokenString);
	}

	public Token ScanToken() {
		SkipWhitespace();

		str.Ptr += str.Length;
		str.Length = 0;

		if (IsAtEnd()) return MakeToken(.TokenEOF);

		char8 c = Advance();

		if (IsAlpha(c)) return Identifier();
		if (IsDigit(c)) return Number();


		switch (c) {
		case '(': return MakeToken(.TokenLeftParen);
		case ')': return MakeToken(.TokenRightParen);
		case '{': return MakeToken(.TokenLeftBrace);
		case '}': return MakeToken(.TokenRightBrace);
		case ';': return MakeToken(.TokenSemiColon);
		case ',': return MakeToken(.TokenComma);
		case '.':
			if (Match('.')) {
				if (Match('.')) {
					return MakeToken(.TokenSpreadRest);
				}
				return ErrorToken("Incomplete '...'");
			} 
			return MakeToken(.TokenDot);
		case '-': return MakeToken(.TokenMinus);
		case '+': return MakeToken(.TokenPlus);
		case '/': return MakeToken(.TokenSlash);
		case '*': return MakeToken(.TokenStar);
		case '!': return MakeToken(Match('=') ? .TokenBangEqual : .TokenBang);
		case '=': return MakeToken(Match('=') ? .TokenEqualEqual : .TokenEqual);
		case '<': return MakeToken(Match('=') ? .TokenLessEqual : .TokenLess);	
		case '>': return MakeToken(Match('=') ? .TokenGreaterEqual : .TokenGreater);
		case '"': return String();
		case '&': if (Match('&')) return MakeToken(.TokenAnd);
		case '|': if (Match('|')) return MakeToken(.TokenOr);
		case '?': return MakeToken(Match('?') ? .TokenCoalesce : (Match('.') ? .TokenNullAccessor : .TokenQuestion));
		}

		return ErrorToken("Unexpected Character");
	}
}