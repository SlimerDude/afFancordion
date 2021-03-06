using afBounce

** Command: Verify
** ###############
**
** When a 'Verify' command is successful, the text should be wrapped in a <span class="success"> tag, to highlight it green.
** 
** Example
** -------
** Fancordion says [Kick Ass!]`verifyEq:greeting`
** 
class CmdVerifyEqSuccessTest : ConTest {
	Str greeting	:= "Kick Ass!"

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success").verifyTextEq("Kick Ass!")
	}
}
