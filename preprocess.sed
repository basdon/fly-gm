#

#s/^##include\s\+"\(.*\)"$/#include "\1"\n#undef _inc_\1/
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

/^hook / {
	s/^hook\s\+\(.*\)()$/#if defined \1/
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

