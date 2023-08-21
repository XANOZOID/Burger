namespace burger;

using System;
using System.Collections;


struct Label {
	public String name = "";
	public bool isConst;
	public bool isUnique;
}

struct Param {
	public String name = "";
	public bool hasDefault = false;
	public bool isRest = false;
}

struct Script {
	public String name = "";
	public List<Param> paramList = new List<Param>();
}

class Parser {

	Scanner scanner;
	List<Script> scripts = new List<Script>();
	List<Label> labels = new List<Label>();

	public this(Scanner scanner) {
		this.scanner = scanner;
	}

	public void Parse() {

		ParseTopLevel();

		scanner.Reset();

		// parse scripts . . .
	}

	

	/**
		This parses for all top level elements.
		It builds information on scripts and labels.
	*/
	void ParseTopLevel() {


		for (;;) {
			var token = scanner.ScanToken();

			switch (token.Type) {
			case .TokenScript: ParseScriptHead();
			case .TokenConst:
				// either "unique" or "label" follows
				token = scanner.ScanToken();

				if (token.Type == .TokenUnique) {
					token = scanner.ScanToken();
				}

				if (token.Type == .TokenLabel) {
					ParseLabel();
				}
			case .TokenLabel:
			default: continue;
			}
		}


	}

	void ParseScriptHead() {

	}

	void ParseLabel() {

	}


}