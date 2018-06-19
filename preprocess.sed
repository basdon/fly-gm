#

#s/^##include\s\+"\(.*\)"$/#include "\1"\n#undef _inc_\1/
/^##include/ {
	s/^.*"\(.*\)"$/#include "\1"/
	# check if the next line is empty first before
	# adding the extra line
	# try to not mess up hold space (using @@@ delim)
	p
	s/^.*"\(.*\)"$/@@@\1/
	H
	N
	s/.*\n//
	s_\s*//.*$__
	/^$/ !{
		c\#error "keep lines after ##include empty"
		q
	}
	g
	s/^\(.*\)@@@.*$/\1/
	x
	s/^.*@@@\(.*\)$/#undef _inc_\1/
}

/^##section/,/^##endsection/ {
	/return/c#error "no return in sections please"
}
s/^##section\s\+\(.*\)$/#if defined \1/
/^##endsection$/ {
	i\#endinput
	N
	c\#endif
}
