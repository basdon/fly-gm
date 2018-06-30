#

# include with include guard removal
/^##include/ {
	s/^.*"\(.*\)"$/#include "\1"/
	# check if the next line is empty first before
	# adding the extra line
	# try to not mess up hold space (using §§§ delim)
	p
	s/^.*"\(.*\)"$/§§§\1/
	H
	N
	s/.*\n//
	s_\s*//.*$__
	/^$/ !{
		c\#error "keep lines after ##include empty"
		q
	}
	g
	s/^\(.*\)§§§.*$/\1/
	x
	s/^.*§§§\(.*\)$/#undef _inc_\1/
}

# custom doc comment formats
/^\/\/@/ {
	s-^//@summary \(.*\)$-/// <summary>\1</summary>-
	s-^//@param \([^ \t]\+\) \(.*\)$-/// <param name="\1">\2</param>-
	s-^//@remarks \(.*\)$-/// <remarks>\1</remarks>-
	s-^//@returns \(.*\)$-/// <returns>\1</returns>-
	s-{@code \([^}]*\)}-<b><c>\1</c></b>-g
	s-{@b \([^}]*\)}-<b>\1</b>-g
	s-{@link \([^}]*\)}-<a href="#\1">\1</a>-g
}

# only allow returns inside hooks if preceded by #allowreturn
# also replaces the end of a hook
/^hook /,/^}$/ {
	/^\s*return/c#error "no return in hooks please"
	/^\s*#allowreturn$/ {
		N
		/.*\n\s*return[$ ]/ !{
			c\#error "#allowreturn should only precede a return statement"
			q
		}
		i
		s/.*\n//
	}
	/^}$/ {
		i\#endinput
		N
		c\#endif
	}
}

# handles the start of a hook
/^hook / {
	s/^hook\s\+\(.*\)(.*)$/#if defined \1/
	# also check first if next line is empty (is '{')
	p
	s/^.*defined \(.*\)$/§§§\1/
	H
	N
	s/.*\n//
	/^{$/ !{
		c\#error "keep lines after hook start '{'"
		q
	}
	g
	s/^\(.*\)§§§.*$/\1/
	x
	s/^.*§§§\(.*\)$/#define SECTION_\1/
}

