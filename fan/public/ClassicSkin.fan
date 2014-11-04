using concurrent

** A Fancordion Skin that mimics the style of the classic Java Concordion library.
class ClassicSkin : FancordionSkin {
	@NoDoc
	override Uri[]	cssUrls		:= [,]
	@NoDoc
	override Uri[]	scriptUrls	:= [,]

	private	 Int	buttonId	:= 0
	private	 Str	cmdElement	:= "span"

	// ---- Setup / Tear Down -------------------

	@NoDoc
	override Void tearDown() {
		cssUrls.clear
		scriptUrls.clear
		buttonId = 0
	}

	// ---- HTML Methods ------------------------

	@NoDoc
	override Str head() {
		addCss(`fan://afFancordion/res/classicSkin/fancordion.css`.get)
		return FancordionSkin.super.head
	}

	@NoDoc
	override Str footer() {
		buf := StrBuf()
		ver	:= Pod.of(this).version
		now := DateTime.now(1sec).toLocale("D MMM YYYY, k:mmaa zzzz 'Time'")
		dur := DateTime.now(null) - fixtureMeta.StartTime
		buf.add("<footer>\n")
		buf.add("""\tResults generated by <a href="http://www.fantomfactory.org/pods/afFancordion">Fancordion v${ver}</a>\n""")
		buf.add("""\t<div class="testTime">in ${dur.toLocale} on ${now}</div>\n""")
		buf.add("</footer>\n")
		return buf.toStr
	}

	@NoDoc
	override Str cmdErr(Str cmdUrl, Str cmdText, Err err) {
		addScript(`fan://afFancordion/res/classicSkin/visibility-toggler.js`.get)

		buttonId++

		stack := err.traceToStr.splitLines.join("") { "<span class=\"stackTraceEntry\">${it.toXml}</span>\n" }
		exp := """<del class="expected">${cmdText.toXml}</del>"""
		html :=
		"""<span class="exceptionMessage">${firstLine2(err.msg).toXml}</span>
		   <input id="stackTraceButton${buttonId}" type="button" class="stackTraceButton" onclick="javascript:toggleStackTrace('${buttonId}')" value="View Stack" />
		   <span class="stackTrace" id="stackTrace${buttonId}">
		     <span>While evaluating command: <code>${cmdUrl}</code></span>
		     <span class="stackTraceExceptionMessage">${err.typeof} : ${err.msg.toXml}</span>
		     ${stack}
		   </span>
		   """
		if (inTable)
			html = """<td class="error">${exp}\n${html}</td>"""
		else
			html = """<span class="error">${exp}</span>\n${html}"""
		return html
	}
	
	private Str firstLine2(Str? txt) {
		txt?.splitLines?.exclude { it.trim.isEmpty }?.first ?: Str.defVal
	}
	
	private Bool inTable() {
		Actor.locals.containsKey("afFancordion.inTable")
	}
}
