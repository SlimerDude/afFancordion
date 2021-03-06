using afBounce

** Command: Run
** ############
**
** A Test Command links to another fancordion fixture. If the fixture passes, it is displayed in green. 
** 
** Example
** -------
**  - Linking to [another Test instance]`run:CmdRunSuccessTest_Test`
**  - Linking to [a Fixture instance]`run:CmdRunSuccessTest_Fixture`
** 
class CmdRunSuccessTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		verifyEq(Element("ul a")[0]["href"], "CmdRunSuccessTest_Test.html")
		verifyEq(Element("ul span.success > a")[0].text, "another Test instance")

		verifyEq(Element("ul a")[1]["href"], "CmdRunSuccessTest_Fixture.html")
		verifyEq(Element("ul span.success > a")[1].text, "a Fixture instance")
	}
}

