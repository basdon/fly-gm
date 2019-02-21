#

# from outline, put two § chars with indent in between
# check if line is <indent>}, then stop collecting outline
# print outlined functions at hook guards spot

:begin

/\t*#outline/ {
	s/^\(\t*\)#outline.*$/§\1§/
	G
	h
	c// outlined
}

x
/^§/ {
	x
	H
	g
	# check same indent by getting the initial indent and the current line,
	# replace \t}\t until no more match and see if result is ^}}$
	s/^§\(\t*\)§.*\n/\1}/
	/\t*}\t*}/ {
:again
		s/\t}\t/}/
		t again
		/^}}$/ {
			x
			s/^§\t*§//
			x
		}
	}
	#/^\(\t*}\)\{2\}$/ {
	#}
	c// outlined
	x
}
x

/^#printhookguards$/ {
	i// == outlined stuff ==
	s/^/\n/
	H
	x
}
