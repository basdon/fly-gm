# modify makefile to add targets for all files in #FILE lines
# between #START and #STOP

1 {
	p
	s/^.*$/@/
	h
	d
}

/^#FILE .\+$/ {
	p
	s/^#FILE //
	s/$/?/
	H
	s_^_ p/_
	s_?__
	s_$_.p_
	G
	h
	d
}

/^#S2$/,/^#S3$/d

/^#STOP$/ {
	i#S2
	i
	g
	s/@.*$//
	s/\n//g
	s_^_build: p/sharedsymbols.p_
	p
	s/^.*$/	@echo./p
	i
	g
	s/^.*@\n//
	s/\n//g
	h
	:next
		s/^[^?]*?//
		x
		s/?.*$//
		s_^\(.*\)$_p/\1.p: \1.pwn $(ppfile)\n	$(pp) \1.pwn>p/\1.p_p
		i
		g
		/^$/!b next
	i#S3
	c#STOP
}

