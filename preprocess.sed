#
s/^##include "\(.*\)"$/#include "\1"\n#undef _inc_\1/g
