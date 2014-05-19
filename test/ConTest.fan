using concurrent
using afSizzle

abstract class ConTest : ConcordionTest {
	
	override Void testFixture() {
		this.concordionResults = ConcordionRunner().runTest(this.typeof, `file:///C:/Projects/Fantom-Factory/Concordion/test/${this.typeof.name}.fan`.toFile)

		result := concordionResults.result
		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	abstract Void doTest()	
}
