namespace burger;
using System;
using System.IO;


class Program {
	
	public static void Main() {
		String rootDir = scope .();
		Directory.GetCurrentDirectory(rootDir);

		let filePath = Path.InternalCombine(.. scope .(), rootDir, "src", "test", "basic.brg");

		String text = new String();
		if (File.ReadAllText(filePath, text) case .Ok) {
			Console.Write(text);

			var s = new Scanner(text);
			var p = new Parser(s);
			p.Parse();
		}
		
		Console.Read();
	}

}