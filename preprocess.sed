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
		/\s*\/\.*$/ !{
			c\#error "keep lines after ##include empty"
			q
		}
	}
	g
	s/^\(.*\)§§§.*$/\1/
	x
	s/^.*§§§\(.*\)$/#undef _inc_\1/
}

# include with include guard removal not giving a shit about line nums
/^###include/ {
	s/^.*"\(.*\)".*$/#include "\1"/p
	s/^.*"\(.*\)".*$/#undef _inc_\1/
}

# custom doc comment formats
/^\s*\/\/@/ {
	s-^\s*//@summary \(.*\)$-/// <summary>\1</summary>-
	s-^\s*//@param \([^ \t]\+\) \(.*\)$-/// <param name="\1">\2</param>-
	s-^\s*//@remarks \(.*\)$-/// <remarks>\1</remarks>-
	s-^\s*//@returns \(.*\)$-/// <returns>\1</returns>-
	s-^\s*//@seealso \(.*\)$-/// <seealso name="\1"/>-
	s-{@code \([^}]*\)}-<b><c>\1</c></b>-g
	s-{@b \([^}]*\)}-<b>\1</b>-g
	s-{@bold \([^}]*\)}-<b>\1</b>-g
	s-{@link \([^}]*\)}-<a href="#\1">\1</a>-g
	s-{@param \([^}]*\)}-<paramref name="\1"/>-g
}

# hooked sections
/^##section/ {
	x
	/§se§/ {
		c#error "cannot start a section while already in a section"
		q
	}
	x
	s/##section\s\+/#define @/p
	s/^.*\s\+\(.*\)$/\1§se§/
	H
	d
}

/^##endsection/ {
	g
	/§se§/ !{
		c#error "cannot end section because none was started"
		q
	}
	s/^\(.*\)\n\(.*\)§se§\(.*\)$/\1\3§§§\2/
	h
	s/^\(.*\)§§§.*$/\1/
	x
	s/^.*§§§/#undef /
}

# varinit syntactic sugar
s/^varinit$/hook varinit()/

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
	s/^\s*#return /return /
	/^}$/ {
		i\#endinput
		N
		c\#endif
	}
}

# handles the start of a hook
/^hook / {
	s/^hook\s\+\(.*\)(.*)$/#if defined @\1/
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
	s/^.*§§§\(.*\)$/\1§§§/
	G
	/§ns§/ !{
		c#error "can't hook without having a namespace!"
		q
	}
	s/^\(.*\)§§§.*\n\(.*\)§ns§.*$/\2_\1§hg§/
	s/^\(.*\)§§§\(.*\)§ns§.*$/\2_\1§hg§/
	H
	s/^/#define /
	s/§hg§//
}

# hook guards
/^#printhookguards/ {
	i// hookguards start
:nextguard
	g
	/§hg§/ {
		s/^.*\n\(.*\)§hg§.*$/#if !defined \1\n#error "missing \1 \\\
		(either missing or name too long or in unexpected hook)"\n#endif/p
		g
		s/^\(.*\)\n.*§hg§\(.*\)$/\1\2/
		x
		b nextguard
	}
	#c// hookguards end
	g
	s-^.*\n\(.*\)§ns§.*$-\
		// hookguards end\
		#if defined \1_hookguards\
		#error "multiple inclusion"\
		#endif\
		#define \1_hookguards-
}

# namespaces
/^#namespace / {
	s/^#namespace\s\+"\(.*\)"$/\1§ns§/
	H
	# remove previous namespace, if there's one
	g
	s/[^\n][^§]\+§ns§\(.*\)§ns§/\1§ns§/
	x
	c
}

# ifdef ifndef syntactic sugar
s/^\(\s*\)#ifdef/\1#if defined/
s/^\(\s*\)#ifndef/\1#if !defined/

# foreach syntactic sugar
s/foreach \?(new \(.*\): \?\(.*\)) \?{/for (new iv@\1 : \2) {new \1=iter_access(\2,iv@\1)/

