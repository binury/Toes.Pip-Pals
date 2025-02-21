using GDWeave;
using Seent.util.LexicalTransformer;
using static Seent.util.LexicalTransformer.TransformationPatternFactory;

namespace Seent;

public class Mod : IMod
{
	public Config Config;

	public Mod(IModInterface mi)
	{
		Config = mi.ReadConfig<Config>();
		mi.RegisterScriptMod(new TransformationRuleScriptModBuilder()
			.ForMod(mi)
			.Named("Seent")
			.Patching("res://Scenes/Entities/Player/player_label.gdc")

			.AddRule(new TransformationRuleBuilder()
				.Named("Var declare")
				.Do(Operation.Append)
				.Matching(CreateGdSnippetPattern("var player_id = - 1"))
				.With(
					"""

					onready var Seent = get_node("/root/ToesSeent")

					"""
					)
				.When(true)
			)

			.AddRule(new TransformationRuleBuilder()
				.Named("Rename name label")
				.Do(Operation.Append)
				.Matching(CreateGdSnippetPattern("_name = _name.replace(\"]\", \"\")\n"))
				.With("\n_name = (Seent.get_times_seen_badge(str(player_id)) + _name)\n$VBoxContainer/Label.fit_content_height = true\n", 1)
				.When(true)
			)

			.Build()
		);
	}

	public void Dispose() { }
}
