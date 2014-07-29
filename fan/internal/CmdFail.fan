using afBeanUtils::TypeCoercer

** The 'fail' command throws a 'TestErr' with the given message.
** 
** pre>
** ** The meaning of life is [42]`fail:TODO`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdFail : Command {
	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		msg := pathStr(cmdUrl).isEmpty ? "Fail" : pathStr(cmdUrl)
		fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(cmdText, msg))
	}	
}
