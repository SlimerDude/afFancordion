using fandoc

internal class FixtureDocWriter : DocWriter {
	private Bool 				inLink
	private Bool 				inPre
	private StrBuf?				linkText
	private Bool 				inSection
	
	private |Str, Int->Bool|[]	sectionFuncs
	private Commands 			cmds
	private FixtureCtx			fixCtx
	
	new make(Commands cmds, |Str, Int->Bool|[] sectionFuncs, FixtureCtx fixCtx) {
		this.cmds			= cmds
		this.sectionFuncs	= sectionFuncs
		this.fixCtx			= fixCtx
	}
	
	override Void docStart(Doc doc) {
		fixCtx.skin.html
		fixCtx.skin.head
		fixCtx.skin.headEnd
		fixCtx.skin.body
	}
	
	override Void docEnd(Doc doc) {
		if (inSection) {
			inSection = false
			fixCtx.skin.sectionEnd
		}		
		fixCtx.skin.bodyEnd
		fixCtx.skin.htmlEnd
	}
	
	override Void elemStart(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.link:
				inLink = true
				linkText = StrBuf()
				
			case DocNodeId.heading:
				head := elem as Heading
				
				if (inSection) {
					inSection = false
					fixCtx.skin.sectionEnd
				}
				
				// TODO: contribute section titles
				// even better, contribute functions! so that titles can have custom content
				if (sectionFuncs.any { it(head.title.trim, head.level) }) {
					inSection = true
					fixCtx.skin.section
				}
				
				fixCtx.skin.heading(head.level, head.title, head.anchorId)
			
			case DocNodeId.para:
				para := elem as Para
				fixCtx.skin.p(para.admonition)
			
			case DocNodeId.pre:
				inPre = true
				linkText = StrBuf()
			
			case DocNodeId.blockQuote:
				fixCtx.skin.blockQuote
			
			case DocNodeId.orderedList:
				list := elem as OrderedList
				fixCtx.skin.ol(list.style)
			
			case DocNodeId.unorderedList:
				fixCtx.skin.ul

			case DocNodeId.listItem:
				fixCtx.skin.li

			case DocNodeId.emphasis:
				fixCtx.skin.em

			case DocNodeId.strong:
				fixCtx.skin.strong

			case DocNodeId.code:
				fixCtx.skin.code

			case DocNodeId.image:
				image := elem as Image
				fixCtx.skin.img(image.uri.toUri, image.alt)

			default:
				throw Err("WTF is a ${elem.id} element???")
		}
	}
	
	override Void text(DocText docText) {
		if (inLink || inPre) {
			linkText.out.print(docText.str)
			return
		}

		fixCtx.skin.text(docText.str)
	}

	override Void elemEnd(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.link:
				inLink = false
				cmds.doCmd(fixCtx, ((Link) elem).uri, linkText.toStr, null, null, null)
				linkText = null
				
			case DocNodeId.pre:
				inPre	  = false
				preText  := linkText.toStr
				linkText  = null
				preLines := preText.splitLines
				cmdUrl	 := preLines.first.trim
				if (!preLines.isEmpty && cmds.isCmd(cmdUrl.toUri.scheme)) {
					preLines.removeAt(0)
					preText = preLines.join("\n")
					
					// TODO: fix this dirty hack that prevents tables from being rendered in a <pre> tag
					if (cmdUrl.toUri.scheme == "table")
						cmds.doCmd(fixCtx, cmdUrl, preText.trim, null, null, null)
					else {
						fixCtx.skin.inPre = true
						cmds.doCmd(fixCtx, cmdUrl, preText.trim, null, null, null)
						fixCtx.skin.inPre = false
					}
					
				} else {
					fixCtx.skin.pre
					fixCtx.skin.text(preText)
					fixCtx.skin.preEnd
				}
			
			case DocNodeId.heading:
				head := elem as Heading
				fixCtx.skin.headingEnd(head.level)
		
			case DocNodeId.para:
				para := elem as Para
				fixCtx.skin.pEnd
			
			case DocNodeId.blockQuote:
				fixCtx.skin.blockQuoteEnd
			
			case DocNodeId.orderedList:
				list := elem as OrderedList
				fixCtx.skin.olEnd
			
			case DocNodeId.unorderedList:
				fixCtx.skin.ulEnd

			case DocNodeId.listItem:
				fixCtx.skin.liEnd

			case DocNodeId.emphasis:
				fixCtx.skin.emEnd

			case DocNodeId.strong:
				fixCtx.skin.strongEnd

			case DocNodeId.code:
				fixCtx.skin.codeEnd

			case DocNodeId.image:
				null?.toStr

			default:
				throw Err("WTF is a ${elem.id} element???")
		}
	}
}
