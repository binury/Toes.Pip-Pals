using GDWeave;

namespace Seent;

public class Mod : IMod
{
	public Config Config;

	public Mod(IModInterface mi)
	{
		Config = mi.ReadConfig<Config>();
		mi.RegisterScriptMod(new PPMod(mi));
	}

	public void Dispose() { }
}
