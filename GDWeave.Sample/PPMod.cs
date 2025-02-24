using GDWeave;
using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

public class PPMod(IModInterface mi) : IScriptMod
{
	public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player_label.gdc";

	// private bool _shouldM0 = true;
	// private bool _shouldM1 = true;

	public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
	{

		// var label = ""
		var match0 = new MultiTokenWaiter([
			t => t.Type == TokenType.PrVar,
			t => t is IdentifierToken { Name: "label" },
			t => t.Type == TokenType.OpAssign,
			t => t is ConstantToken { Value: StringVariant { Value: "" } },
			t => t.Type == TokenType.Newline,
		]);
		//"_name = _name.replace(\"]\", \"\")\n"))
		var match1 = new MultiTokenWaiter([
			t => t is IdentifierToken {Name: "_name"},
			t => t.Type == TokenType.OpAssign,
			t => t is IdentifierToken {Name: "_name"},
			t => t.Type == TokenType.Period,
			t => t is IdentifierToken {Name: "replace"},
			t => t.Type == TokenType.ParenthesisOpen,
			t => t is ConstantToken {Value: StringVariant { Value: "]"}},
			t => t.Type == TokenType.Comma,
			t => t is ConstantToken {Value: StringVariant { Value: ""}},
			t => t.Type == TokenType.ParenthesisClose,
			t => t.Type == TokenType.Newline,
		]);

		foreach (var token in tokens)
		{
			// mi.Logger.Debug(token.ToString());
			if (match0.Check(token))
			{
				mi.Logger.Debug("Matched PP!!!!!!!!!! (1/2)");
				// onready var Seent = get_node('/root/ToesSeent')
				yield return token;
				yield return new Token(TokenType.Newline, 0);
				yield return new Token(TokenType.PrOnready);
				yield return new Token(TokenType.PrVar);
				yield return new IdentifierToken("Seent");
				yield return new Token(TokenType.OpAssign);
				yield return new Token(TokenType.Dollar);
				yield return new ConstantToken(new StringVariant("/root/ToesSeent"));
				yield return new Token(TokenType.Newline, 0);
			}
			else if (match1.Check(token))
			{

				// var seen_badge = $"/root/ToesSeent".get_times_seen_badge(str(player_id))
				// if self.player_id != -1:
				// _name = seen_badge + "\n" + _name
				mi.Logger.Debug("PP Successfully injected!!!!! (2/2)");
				yield return new Token(TokenType.Newline, 1);
				yield return new Token(TokenType.CfIf);
				// not sure if his will work
				yield return new IdentifierToken("player_id");
				yield return new Token(TokenType.OpNotEqual);
				yield return new ConstantToken(new IntVariant(-1));
				yield return new Token(TokenType.Colon);
				yield return new IdentifierToken("_name");
				yield return new Token(TokenType.OpAssign);
				yield return new IdentifierToken("Seent");
				yield return new Token(TokenType.Period);
				yield return new IdentifierToken("get_times_seen_badge");
				yield return new Token(TokenType.ParenthesisOpen);
				yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextStr);
				yield return new Token(TokenType.ParenthesisOpen);
				yield return new IdentifierToken("player_id");
				yield return new Token(TokenType.ParenthesisClose);
				yield return new Token(TokenType.ParenthesisClose);
				yield return new Token(TokenType.OpAdd);
				yield return new IdentifierToken("_name");
				yield return new Token(TokenType.Newline, 1);

				// yield return new IdentifierToken("PlayerData");
				// yield return new Token(TokenType.Period);
				// yield return new IdentifierToken("_send_notification");
				// yield return new Token(TokenType.ParenthesisOpen);
				// yield return new ConstantToken(new StringVariant("PLAYER_ID WAS: "));
				// yield return new Token(TokenType.OpAdd);
				// yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextStr);
				// yield return new Token(TokenType.ParenthesisOpen);
				// yield return new IdentifierToken("player_id");
				// yield return new Token(TokenType.ParenthesisClose);
				// yield return new Token(TokenType.ParenthesisClose);
			}
			else
			{
				yield return token;
			}

		}
	}
}
