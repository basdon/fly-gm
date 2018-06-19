#
s/^##include "\(.*\)"$/#include "\1"\n#undef _inc_\1/g

/^##section/,/^##endsection/ {
	/return/c#error "no return in sections please"
}
s/^##section\s\+\(.*\)$/#if defined \1/
/^##endsection$/ {
	i\#endinput
	N
	c\#endif
}
