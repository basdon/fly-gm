
// vim: set filetype=c ts=8 noexpandtab:

//@summary Url encodes given string.
//@param data string to encode
//@param len amount of characters in {@param data}
//@param output buffer to store result in (should be at least {@code len * 3} of size)
//@remarks Does {@b not} add a zero terminator.
//@returns Amount of charactes written.
urlencode(const data[], len, output[])
{
	for (new i = 0, oi = 0; i < len; i++, oi += 3) {
		output[oi] = '%'
		format output[oi + 1], 3, "%02x", data[i]
	}
	return len * 3
}

