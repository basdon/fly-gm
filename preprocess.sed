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

/^>>/,/^<<$/ {
	/^\s*return/c#error "no return in sections please"
	/^\s*#allowreturn$/ {
		N
		/.*\n\s*return[$ ]/ !{
			c\#error "#allowreturn should only precede a return statement"
			q
		}
		i
		s/.*\n//
	}
}

s/^>>\s\+\(.*\)$/#if defined \1/
/^<<$/ {
	i\#endinput
	N
	c\#endif
}
