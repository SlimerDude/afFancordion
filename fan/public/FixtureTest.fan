
** Implement to convert a Test class into a Concordion fixture.
@Fixture
mixin FixtureTest {

	** Runs this Test class as a Concordion fixture. 
	** This method name is prefixed with 'test' so it is picked up by 'fant' and other test runners.
	virtual Void testFixture() {
		runner := ((ConcordionRunner?) ThreadStack.peek("afConcordion.runner", false)) ?: concordionRunner
		result := runner.runFixture(this)

		if (!result.errors.isEmpty)
			throw result.errors.first
	}
	
	** Returns a fresh instance of a 'ConcordionRunner'.
	** 
	** Override to change default runner values and / or supply suite setup & teardown methods.
	virtual ConcordionRunner concordionRunner() {
		ConcordionRunner()
	}
}
