using concurrent

internal class CmdTest : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {		
		testPod := fixCtx.fixtureInstance.typeof.pod
		
		// todo: allow qnames to test multiple pods
		// maybe not - 'cos then we also need to qualify the output file name
		newType		:= testPod.type(cmdUrl.pathStr, false)
		if (newType == null) {
			// TODO: scan file system for type and load fixture as script
			// but currently our runner is only launched via fant which only runs from a pod 
			// actually - that's a lie, fant can run scripts too! - http://fantom.org/doc/docTools/Fant.html#running
			throw Err("Wot no Fixture?")
		}
		
		// ensure it's a fixture so we have an output HTML file to link to
		// we could link to unit tests - but then we'd need to make it look pretty.
		// save it for the next project - or a plugin!
		if (!newType.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(newType))

		try {
			if (newType.fits(Test#)) {
				// if only fant was written in Fantom!
				testMethods := newType.methods.findAll { it.name.startsWith("test") && it.params.isEmpty && !it.isAbstract }
				testMethods.each {  
					newInstance := (Test) newType.make
					
					try {
						newInstance.setup
						it.callOn(newInstance, null)
						newInstance.teardown
						
					} finally {
						// notch up / carry over some verify counts
						verifies := (Int) newInstance->verifyCount
						if (fixCtx.fixtureInstance is Test)
							verifies.times { ((Test) fixCtx.fixtureInstance).verify(true) }
					}
				}
				
			} else {
				newInstance := newType.make
				
				runner := (ConcordionRunner) ThreadStack.peek("afConcordion.runner")
				result := runner.runFixture(newInstance)
				if (!result.errors.isEmpty)
					throw result.errors.first
			}
			
			last := (FixtureResult) Actor.locals["afConcordion.lastResult"]
			link := fixCtx.skin.a(last.resultFile.name.toUri, cmdText)
			succ := fixCtx.skin.cmdSuccess(link, false)
			fixCtx.renderBuf.add(succ)

		} catch (Err err) {
			fixCtx.errs.add(err)
			last := (FixtureResult) Actor.locals["afConcordion.lastResult"]
			link := fixCtx.skin.a(last.resultFile.name.toUri, cmdText)
			fail := fixCtx.skin.cmdFailure(link, err.msg, false)
			fixCtx.renderBuf.add(fail)
		}
	}
}
