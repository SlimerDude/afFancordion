using afBounce

** Command: Set
** ############
**
** Set commands should set fields to the wrapped value.
** 
** Example
** -------
** If I set 'name' equal to " [Bob]`set:name` " then I expect 'name' to equal " [Bob]`verify:eq(name)` "!
** 
class CmdSetTest : ConTest {
	Str? name := "Wotever"
	
	override Void doTest() {
		Element("span.success").verifyTextEq("Bob")
	}
}